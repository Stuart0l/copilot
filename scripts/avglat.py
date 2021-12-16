path_prefix = "/home/xuhao/copilot/experiments/latest/"

def calc_average_latency(filename):
	with open(filename, 'r') as f:
		n_client = 0
		total = 0
		for line in f:
			total += float(line.split('\t')[9])
			n_client += 1
		print("{:.4f}".format(total / n_client))


if __name__ == '__main__':
	
	calc_average_latency(path_prefix + 'clients.tputlat.txt')