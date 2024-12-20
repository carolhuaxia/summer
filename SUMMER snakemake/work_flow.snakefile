# Where all the output will be saved
import os,re
BASE_OUTPUT_DIR = config['BASE_OUTPUT_DIR']
if not os.path.exists(BASE_OUTPUT_DIR):
	os.makedirs(BASE_OUTPUT_DIR)
	
# Defines reference file
REFFILE = config['BASE_REF_DIR']

# Defines input file
INPUTFILE = config['BASE_INPUT_DIR']

# Defines number of threads
THREADS = int((config['THREADS']-1)/2)

list_target_files = []
temp = expand("{BASE_OUTPUT_DIR}/sample_sniffles2.vcf",BASE_OUTPUT_DIR = BASE_OUTPUT_DIR)
list_target_files.append(temp)
temp = expand("{BASE_OUTPUT_DIR}/svimoutput",BASE_OUTPUT_DIR = BASE_OUTPUT_DIR)
list_target_files.append(temp)
temp = expand("{BASE_OUTPUT_DIR}/cutesvout.vcf",BASE_OUTPUT_DIR = BASE_OUTPUT_DIR)
list_target_files.append(temp)

rule all:
	input:
		list_target_files
		
rule sniffles:
	input:
		INPUTFILE
	output:
		"{BASE_OUTPUT_DIR}/sample_sniffles2.vcf"
	shell: "sniffles --threads {THREADS} --input {input} --vcf {output} --reference {REFFILE}"

rule svim:
	input:
		INPUTFILE
	output:
		"{BASE_OUTPUT_DIR}/svimoutput"
	shell: "conda run -n svim_env svim alignment --min_sv_size 50 {BASE_OUTPUT_DIR} {input} {REFFILE}"

rule cuteSV:
	input:
		INPUTFILE
	output:
		"{BASE_OUTPUT_DIR}/cutesvout.vcf"
	shell: "cuteSV --max_cluster_bias_INS 100 --diff_ratio_merging_INS 0.3 --max_cluster_bias_DEL 100 --diff_ratio_merging_DEL 0.3 --genotype -q 20 -r 50 -L 50000000 -t {THREADS} -s 2 {input} {REFFILE} {output} {BASE_OUTPUT_DIR}"
		