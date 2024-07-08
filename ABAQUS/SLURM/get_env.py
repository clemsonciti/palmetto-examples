import subprocess
output = subprocess.check_output(['srun', 'hostname']).decode('utf-8')
output = output.split('\n')[:-1]
output_set = set(output)
output_dic = { i:output.count(i) for i in output_set}
#make a string
string = "mp_host_list=[" 
for k,v in output_dic.items():
    string += "["
    string += "'"
    string += str(k)
    string += "'"
    string += ","
    string += str(v)
    string += "],"
string += "]"

with open("abaqus_v6.env", "w") as f:
    f.write(string)
