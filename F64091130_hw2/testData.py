import random

output_filename = "Gold.dat"
total_cycles = 100
max_count = 29
current_count = 0

with open(output_filename, 'w') as file:
    for cycle in range(total_cycles):
        if cycle == 0 or cycle == 50 or cycle == 100:
            reset = 1
        else:
            reset = 0

        if cycle < 32:
            sel = 0  # up
        elif cycle < 55:
            sel = 1  # down
        else:
            sel = random.choice([0, 1])
        
        # 測試en = 0 (hold counter value)
        if cycle > 35 and cycle < 40:
            en = 0
            sel = random.choice([0, 1])
        else:
            en = 1

        if reset == 1:
            next_count = 0
        elif en == 1:
            if sel == 0:
                next_count = current_count + 1 if current_count < max_count else max_count
            else:
                next_count = current_count - 1 if current_count > 0 else 0
        else:
            next_count = current_count
        
        # 将reset, en, sel直接输出，next_count转换为16进制格式，确保宽度为两个字符
        file.write(f"{reset}_{en}_{sel}_{next_count:02X}\n")
        
        current_count = next_count
