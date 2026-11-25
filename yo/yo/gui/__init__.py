"""The graphical interface (GTK 4 and libadwaita)."""


def main(root=None, profile=None, page=None) -> int:
    from .app import run
    return run(root, profile, page)
