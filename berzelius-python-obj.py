from termcolor import colored
import random as r
import copy

colors = ["red", "green", "yellow", "blue", "magenta", "cyan", "white"]

class Water:
    def __init__(self, color, size):
        self.color = color
        self.size = size

class Glass:
    def __init__(self, max_water_level, color, i):
        self.max_water_level = max_water_level
        self.index = i
        if color == "empty":
            self.waters = []
        else:
            self.waters = [Water(color, self.max_water_level)]
    
    def water_level(self):
        level = 0
        for water in self.waters:
            level += water.size
        return level

    def is_empty(self):
        return self.water_level() == 0

    def is_full(self):
        return self.water_level() == self.max_water_level

    def one_color(self):
        return len(self.waters) == 1

    def top(self):
        if self.is_empty():
            return Water("empty", 0)
        else:
            return self.waters[-1]

class Pour:
    def __init__(self, a, b, size):
        self.a = a
        self.b = b
        self.size = size

    def equal_color(self):
        return self.a.top().color == self.b.top().color

    def is_possible_setup(self):
        if self.size <= 0:
            return False
        if self.a == self.b:
            return False
        if self.a.is_empty():
            return False
        if not self.a.one_color() and self.a.top().size < 2:
            return False
        if self.a.one_color():
            if self.size > self.a.top().size:
                return False
        else:
            if self.size > self.a.top().size - 1:
                return False
        if self.b.water_level() + self.size > self.b.max_water_level:
            return False
        if (not self.b.is_empty()) and (not self.a.is_full()) and self.equal_color():
            return False
        return True

    def is_possible_pour(self):
        if self.b.water_level() == self.b.max_water_level:
            return False
        if not (self.b.is_empty() or self.equal_color()):
            return False
        return True

    def color(self):
        return self.a.top().color

    def inv(self):
        return Pour(self.b, self.a, self.size)

class GlassList:
    def __init__(self, full_glass_number, empty_glass_number, max_water_level):
        self.max_water_level = max_water_level
        assert full_glass_number >= len(colors)
        self.colors = colors[:full_glass_number]
        self.glasses = [Glass(max_water_level, color, i) for i, color in enumerate(self.colors)] + [Glass(max_water_level, "empty", i+full_glass_number) for i in range(empty_glass_number)]
        self.glass_number = len(self.glasses)
        self.mix_number = 0
        self.mix_history = []
        self.play_history = []

    def correct_water_numbers(self):
        for color in self.colors:
            color_number = 0
            for glass in self.glasses:
                for water in glass.waters:
                    if water.color == color:
                        color_number += water.size
            if color_number > self.max_water_level:
                return False
        return True

    def history_entry(self, pour, color):
        return (pour.a.index, pour.b.index, pour.size, color)

    def in_mix_history(self, pour):
        return self.history_entry(pour.inv(), pour.color()) in self.mix_history

    def get_possible_setup_pours(self):
        pours = []
        for a in self.glasses:
            for b in self.glasses:
                for size in range(1, self.max_water_level):
                    pour = Pour(a, b, size)
                    if pour.is_possible_setup() and not self.in_mix_history(pour):
                        pours.append(pour)
        max_pours = []
        if len(pours) > 0:
            max_pour_size = max([pour.size for pour in pours])
            for pour in pours:
                if pour.size == max_pour_size:
                    max_pours.append(pour)
        return max_pours

    def do_pour(self, pour):
        assert pour.is_possible_setup() or pour.is_possible_pour()
        if not pour.b.is_empty() and pour.equal_color():
            self.glasses[pour.b.index].waters[-1].size += pour.size
        else:
            self.glasses[pour.b.index].waters.append(Water(pour.a.top().color, pour.size))
        if pour.a.top().size > pour.size:
            self.glasses[pour.a.index].waters[-1].size -= pour.size
        else:
            self.glasses[pour.a.index].waters.pop(-1)

    def setup_mix(self, setup_mix_number):
        for i in range(setup_mix_number):
            try:
                pour = r.choice(self.get_possible_setup_pours())
            except IndexError:
                return
            self.mix_history.append(self.history_entry(pour, pour.color()))
            self.do_pour(pour)
            assert self.correct_water_numbers()

    def undo(self):
        b, a, size, color = self.play_history[-1]
        pour = Pour(self.glasses[a], self.glasses[b], size)
        assert pour.is_possible_setup()
        self.play_history.pop(-1)
        L.do_pour(pour)

    def get_lines(self):
        lines = [["transparent" for i in range(self.glass_number)] for j in range(self.max_water_level)]
        for i, glass in enumerate(self.glasses):
            n = 3
            for water in glass.waters:
                for j in range(water.size):
                    lines[n][i] = water.color
                    n -= 1
        return lines

    def print_glasses(self):
        lines = self.get_lines()
        for line in lines:
            for color in line:
                if color == "transparent":
                    print("    ", end='')
                else:
                    print(colored("█   ", color), end='')
            print()
        for i in range(self.glass_number):
            print(str(i), end="   ")
        print()

    def done(self):
        for glass in self.glasses:
            if not (glass.is_full() or glass.is_empty()):
                return False
        return True

if __name__ == "__main__":
    full_glass_number = 7
    empty_glass_number = 2
    max_water_level = 4
    setup_mix_number = 37
    r.seed(2)

    L = GlassList(full_glass_number, empty_glass_number, max_water_level)
    L.setup_mix(setup_mix_number)
    L_at_start = copy.deepcopy(L)

    while not L.done():
        L.print_glasses()
        a = input("From[/U/R]: ")
        while a not in ["U", "R"] and L.glasses[int(a)].is_empty():
            print("This glass is empty. Try again.")
            a = input("From[/U/R]: ")
        if a == "U":
            L.undo()
        elif a == "R":
            L = copy.deepcopy(L_at_start)
        else:
            a = int(a)
            b = int(input("To: "))
            pour = Pour(L.glasses[a], L.glasses[b], L.glasses[a].top().size)
            while not pour.is_possible_pour() and a != b:
                print(f"It is not possible to pour from {a} to {b}. Try again.")
                b = int(input("To: "))
                pour = Pour(L.glasses[a], L.glasses[b], L.glasses[a].top().size)
            if a != b:
                L.play_history.append(L.history_entry(pour, pour.color()))
                L.do_pour(pour)
    L.print_glasses()
    print("Yay! you did it!")

