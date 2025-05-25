from GitArchive import GitArchive
from os.path import exists, join


def download(garchive: GitArchive):
	paths = garchive.download()
	download_info_fp = join(garchive.root, "download_info")
	with open(download_info_fp, "w") as f:
		for path in sorted(paths, key=lambda p: p.path()):
			f.write(f"{path.path()}\n")

def upload(garchive, files: list[str]):
	for ind, file in enumerate(files):
		tag = f"v{ind + 1}"
		desc = f"Release {ind + 1}"
		name = f"Release of file partial {ind + 1}"
		desc = f"Release of file {file}"
		uploaded_files = garchive.new_realease(name, tag, desc, [file])

def read_tk(fp):
	"""
	Read the GitHub token from a file.
	Args:
		fp (str): The file path where the GitHub token is stored.
	Returns:
		str: The GitHub token if it exists, otherwise None.
	"""
	if exists(fp):
		with open(fp, "r") as f:
			return f.read().strip()
	else:
		return None

if __name__ == "__main__":
	import argparse
	parser = argparse.ArgumentParser(description="Manage DataArchive operations.")
	parser.add_argument('--repo', type=str, required=True, help='Name of the repository')
	parser.add_argument('command', choices=['upload', 'download'], help='Command to execute (upload or download)')
	parser.add_argument('--files', nargs='+', type=str, help='Path(s) to the file(s) or directory(ies) to upload')
	parser.add_argument("--root", default="temp", type=str, help="Root directory for the repository.")
	parser.add_argument("--max_thread", default=8, type=int, help="Max threads for downloading.")
	args = parser.parse_args()
	TOKEN_FN = "github.tk"
	gToken = read_tk(TOKEN_FN) if exists(TOKEN_FN) else str(input("Please provide github token (optional):"))
	garchive = GitArchive(args.repo, args.root, gToken, args.max_thread)
	if args.command == 'download':
		download(garchive)
	elif args.command == 'upload':
		if args.files is None:
			raise ValueError("You must specify a file or directory to upload.")
		upload(garchive, args.files)
