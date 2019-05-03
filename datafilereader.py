# reads Empatica data files
filepath = "C:\\Users\\alzfr\\Documents\\study\\data\\"
filename = "EDA.csv"

with open(filepath + filename, 'r') as f:
    lines = f.readlines()
    print(lines)
