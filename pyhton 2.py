def remove_duplicates(s):
    result = ""

    for i in range(len(s)): 
        found = False

        
        for j in range(len(result)):
            if s[i] == result[j]:
                found = True
                break

    
        if not found:
            result += s[i]

    return result

n=input()
print(remove_duplicates(n))  
