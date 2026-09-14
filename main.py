class test1:
    def __init__(self, name: str, age: int):
        self.name = name
        self.age = age

class test2:
    def __init__(self, nameage: str):
        self.nameage = nameage

def transition(obj):
    combined_string = obj.name + ' ' + str(obj.age)
    result_object = test2(combined_string)
    
    return result_object.nameage

arr = [test1("Иван", i) for i in range(100)]

for i in range(100):
    print(transition(arr[i]))