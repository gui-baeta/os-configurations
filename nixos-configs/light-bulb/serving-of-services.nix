{ ... }:
{
	services.nfs.server.enable = true;
	services.nfs.server.exports = ''
	/storage/Pictures         pen-and-paper(rw,async,no_subtree_check)
	'';

	# Enable SSH server
	services.openssh.enable = true;
}