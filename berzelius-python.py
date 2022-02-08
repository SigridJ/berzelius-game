from termcolor import colored
import random as r

def gen_glasses():
    glass_list = []
    for i in range(full_glass_number):
        glass_list.append([[colors[i], max_water_level]])
    for i in range(empty_glass_number):
        glass_list.append([])
    return glass_list

def water_level(glass):
    water_level = 0
    for water in glass:
        water_level += water[1]
    return water_level

def pour(glass_a, glass_b):
    if glass_a[-1][1] + water_level(glass_b) <= max_water_level:
        if water_level(glass_b) == 0:
            glass_b.append(glass_a[-1])
        else:
            glass_b[-1][1] += glass_a[-1][1]
        glass_a.pop(-1)
    else:
        empty_space = max_water_level - water_level(glass_b)
        glass_a[-1][1] -= empty_space
        glass_b[-1][1] += empty_space
    return glass_a, glass_b

def in_history(glass_list, mix_history, a, b):
    print(glass_list)
    new_a, new_b, pour_size = setup_pour(glass_list[a], glass_list[b])
    for mix in mix_history:
        if [b, a, pour_size, new_b[-1][0]] == mix:
            print(glass_list)
            return True
    print(glass_list)
    return False

def possible_glasses(glass_list, mix_history):
    possible_list = []
    for i, glass in enumerate(glass_list):
        if water_level(glass) != 0:
            if len(glass) == 1 or glass[-1][1] > 1:
                if len(possible_setup_pour(glass_list, mix_history, i)) > 0:
                    possible_list.append(i)
    return possible_list

def possible_setup_pour(glass_list, mix_history, a):
    possible_setup_pour_list = []
    for i, glass in enumerate(glass_list):
        if water_level(glass) < max_water_level and i != a:
            if water_level(glass) == 0 or glass_list[a][-1][0] != glass[-1][0] or water_level(glass_list[a]) == max_water_level:
                if not in_history(glass_list, mix_history, a, i):
                    possible_setup_pour_list.append(i)
    possible_pour_sizes = [water_level(glass_list[i]) for i in possible_setup_pour_list]
    possible = []
    if len(possible_pour_sizes) > 0:
        min_water_level = min(possible_pour_sizes)
        print(f"min level: {min_water_level}")
        for glass in possible_setup_pour_list:
            if water_level(glass_list[glass]) == min_water_level:
                possible.append(glass)
    return possible

def possible_pour_size(glass_a, glass_b):
    if len(glass_a) == 1:
        return list(range(1, min(glass_a[-1][1]+1, max_water_level - water_level(glass_b)+1,4)))
    else:
        return list(range(1, min(glass_a[-1][1], max_water_level - water_level(glass_b) +1, 4)))

def setup_pour(glass_a, glass_b):
    pour_size = max(possible_pour_size(glass_a, glass_b))
    if water_level(glass_b) != 0 and glass_b[-1][0] == glass_a[-1][0]:
        glass_b[-1][1] += pour_size
    else:
        glass_b.append([glass_a[-1][0], pour_size])
    if len(glass_a) != 1 or glass_a[-1][1] > pour_size:
        glass_a[-1][1] -= pour_size
    else:
        glass_a.pop(-1)
    return glass_a, glass_b, pour_size

def correct_water_numbers(glass_list):
    for color in colors[:full_glass_number]:
        color_number = 0
        for glass in glass_list:
            for water in glass:
                if water[0] == color:
                    color_number += water[1]
                if color_number > max_water_level:
                    return False
    return True

def setup_mix(glass_list, setup_mix_number):
    mix_number = 0
    mix_history = []
    for i in range(setup_mix_number):
        try: 
            a = r.choice(possible_glasses(glass_list, mix_history))
            print(possible_glasses(glass_list))
        except IndexError:
            print(glass_list)
            return glass_list, mix_number
        try: 
            b = r.choice(possible_setup_pour(glass_list, mix_history, a))
            print(possible_setup_pour(glass_list, a))
        except IndexError:
            print(glass_list)
            return glass_list, mix_number
        print(f"From {a} to {b}")
        glass_list[a], glass_list[b], pour_size = setup_pour(glass_list[a], glass_list[b])
        print(f"Pour size: {pour_size}")
        assert correct_water_numbers(glass_list)
        mix_number += 1
        mix_history.append([a, b, pour_size, glass_list[b][-1][0]])
        glass_print(glass_list)
    return glass_list, mix_number

def possible_pour(glass_a, glass_b):
    if water_level(glass_b) < max_water_level:
        if water_level(glass_b) == 0:
            return True
        else:
            if glass_b[-1][0] == glass_a[-1][0]:
                return True
    return False

def game_done(glass_list):
    for glass in glass_list:
        if water_level(glass) > 0:
            if glass[-1][1] != 4:
                return False
    return True

def get_lines(glass_list):
    lines = [["transparent" for i in range(len(glass_list))] for j in range(max_water_level)]
    for i, glass in enumerate(glass_list):
        n = 3
        for water in glass:
            for j in range(water[1]):
                lines[n][i] = water[0]
                n -= 1
    return lines

def glass_print(glass_list):
    lines_list = get_lines(glass_list)
    for line in lines_list:
        for color in line:
            if color == "transparent":
                print("    ", end='')
            else:
                print(colored("█   ", color), end='')
        print()
    for i in range(len(glass_list)):
        print(str(i), end="   ")
    print()

colors = ["red", "green", "yellow", "blue", "magenta", "cyan", "white"]

full_glass_number = 7
empty_glass_number = 2
max_water_level = 4
setup_mix_number = 37

if __name__ == "__main__":
    glass_list = gen_glasses()
    glass_list, mix_number = setup_mix(glass_list, setup_mix_number)
    print(f"Number of mixes: {mix_number}")
    glass_print(glass_list)
    pour_number = 0
    while not game_done(glass_list):
        a = int(input("From: "))
        while water_level(glass_list[a]) == 0:
            print("This glass is empty. Try again.")
            a = int(input("From: "))
        b = int(input("To: "))
        while (not possible_pour(glass_list[a], glass_list[b])) and a != b:
            print(f"It is not possible to pour from {a} to {b}. Try again.")
            b = int(input("To: "))
        if a != b:
            glass_list[a], glass_list[b] = pour(glass_list[a], glass_list[b])
            pour_number += 1
            glass_print(glass_list)
    print("Yay! you did it!")
    print(f"Number of mixes: {mix_number}")
    print(f"Number of pours: {pour_number}")

