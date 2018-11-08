notlongerthan = 535000000
def main():
    f = open('gamestates', 'r+')
    line_number = 1
    test = []
    label = []
    
    for line in f:
        mylist = line.replace(" ","").replace("[","").replace("]","").replace("(","").replace(")","").replace("'","").replace("\n","").split(",")
        mylist.pop(0)
        if line_number%2 == 0:
            label.append(mylist)
        else:
            test.append(mylist)
        line_number += 1
    
    f.close()
    if len(test) > len(label):
        test.pop()
    
    print("test                                                                label")
    print("==================================================================================")
    for x in range(0, len(test)):
        print(str(test[x]) + "                                         " + str(label[x]))
        
    
main()
