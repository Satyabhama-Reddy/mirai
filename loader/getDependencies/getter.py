import subprocess
out = subprocess.Popen(['sh', 'getDependencies.sh'], 
        stdout=subprocess.PIPE, 
        stderr=subprocess.STDOUT)
out.wait()
unique = []
with open("neededDependencies.txt","r") as f:
    for line in f:
        if(line not in unique and line!="\n"):
            unique.append(line)
print(len(unique))
with open("neededDependencies.txt","w") as f:
    for line in unique:
        f.write(line)