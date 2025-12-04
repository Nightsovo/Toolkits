from pathlib import Path
from typing import Optional


def walk_directory_structure(root: str | Path, max_depth: Optional[int] = None) -> str:
    """
    遍历目录结构并生成文本表示

    Args:
        root: 根目录路径
        max_depth: 最大遍历深度，None表示无限制

    Returns:
        str: 目录结构的文本表示，使用\t缩进，\n换行
    """
    root_path = Path(root)

    if not root_path.exists():
        return f"Error: Path '{root}' does not exist\n"

    if not root_path.is_dir():
        return f"Error: Path '{root}' is not a directory\n"

    result = []

    def _walk(path: Path, prefix: str = "", depth: int = 0):
        """递归遍历目录"""
        # 检查深度限制
        if max_depth is not None and depth > max_depth:
            return

        try:
            # 获取所有子项并排序（目录在前，文件在后）
            items = sorted(path.iterdir(), key=lambda x: (not x.is_dir(), x.name.lower()))

            for item in items:
                # 添加当前项
                result.append(f"{prefix}{item.name}\n")

                # 如果是目录，递归遍历
                if item.is_dir():
                    _walk(item, prefix + "\t", depth + 1)

        except PermissionError:
            result.append(f"{prefix}[Permission Denied]\n")

    # 添加根目录名称
    result.append(f"{root_path.name}/\n")

    # 开始遍历
    _walk(root_path, "\t")

    return "".join(result)


def walk_directory_structure_with_markers(root: str | Path, max_depth: Optional[int] = None) -> str:
    """
    遍历目录结构并生成带树形标记的文本表示

    Args:
        root: 根目录路径
        max_depth: 最大遍历深度，None表示无限制

    Returns:
        str: 目录结构的文本表示，使用树形符号
    """
    root_path = Path(root)

    if not root_path.exists():
        return f"Error: Path '{root}' does not exist\n"

    if not root_path.is_dir():
        return f"Error: Path '{root}' is not a directory\n"

    result = []

    def _walk(path: Path, prefix: str = "", depth: int = 0, is_last: bool = False):
        """递归遍历目录"""
        if max_depth is not None and depth > max_depth:
            return

        try:
            items = sorted(path.iterdir(), key=lambda x: (not x.is_dir(), x.name.lower()))

            for i, item in enumerate(items):
                is_last_item = (i == len(items) - 1)

                # 选择合适的树形符号
                if is_last_item:
                    connector = "└── "
                    extension = "    "
                else:
                    connector = "├── "
                    extension = "│   "

                # 目录添加/后缀
                name = f"{item.name}/" if item.is_dir() else item.name
                result.append(f"{prefix}{connector}{name}\n")

                # 递归遍历子目录
                if item.is_dir():
                    _walk(item, prefix + extension, depth + 1, is_last_item)

        except PermissionError:
            result.append(f"{prefix}[Permission Denied]\n")

    # 添加根目录
    result.append(f"{root_path.name}/\n")
    _walk(root_path, "", 0)

    return "".join(result)


# 使用示例
if __name__ == "__main__":
    # 示例1：简单的tab缩进格式
    print("=== 简单格式 (使用\\t缩进) ===")
    output1 = walk_directory_structure(".", max_depth=2)
    print(output1)

    print("\n=== 树形格式 ===")
    output2 = walk_directory_structure_with_markers(".", max_depth=2)
    print(output2)

    # 保存到文件
    with open("directory_structure.txt", "w", encoding="utf-8") as f:
        f.write(output1)
