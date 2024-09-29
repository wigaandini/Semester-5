import random
import numpy as np

class DiagonalMagicCube:
    def __init__(self, n):
        self.n = n
        self.cube = self.generate_random_cube()
        self.magic_number = self.calculate_magic_number()
        
    def generate_random_cube(self):
        numbers = list(range(1, self.n**3 + 1))
        random.shuffle(numbers)
        return np.array(numbers).reshape((self.n, self.n, self.n))

    def calculate_magic_number(self):
        # Magic number for a cube of size n
        return (self.n * (self.n**3 + 1)) // 2

    def evaluate_penalty(self):
        penalty = 0

        # Check sums of rows
        for i in range(self.n):
            for j in range(self.n):
                if np.sum(self.cube[i, j, :]) != self.magic_number:
                    penalty += 1

        # Check sums of columns
        for i in range(self.n):
            for j in range(self.n):
                if np.sum(self.cube[i, :, j]) != self.magic_number:
                    penalty += 1

        # Check sums of pillars
        for j in range(self.n):
            for k in range(self.n):
                if np.sum(self.cube[:, j, k]) != self.magic_number:
                    penalty += 1

        # Check sums of space diagonals
        if np.sum(np.diagonal(self.cube, axis1=0, axis2=1)) != self.magic_number:
            penalty += 1
        if np.sum(np.diagonal(np.fliplr(self.cube), axis1=0, axis2=1)) != self.magic_number:
            penalty += 1

        # Check diagonal sums in each slice
        for i in range(self.n):
            if np.sum(np.diagonal(self.cube[i, :, :])) != self.magic_number:
                penalty += 1
            if np.sum(np.diagonal(np.fliplr(self.cube[i, :, :]))) != self.magic_number:
                penalty += 1

        return penalty

    def swap(self, index1, index2):
        # Convert linear indices to cube coordinates
        coord1 = np.unravel_index(index1, (self.n, self.n, self.n))
        coord2 = np.unravel_index(index2, (self.n, self.n, self.n))
        self.cube[coord1], self.cube[coord2] = self.cube[coord2], self.cube[coord1]

    def simulated_annealing(self, initial_temp, cooling_rate):
        temp = initial_temp
        current_penalty = self.evaluate_penalty()

        while temp > 1:
            index1, index2 = random.sample(range(self.n**3), 2)
            self.swap(index1, index2)
            new_penalty = self.evaluate_penalty()
            delta = new_penalty - current_penalty

            if delta < 0 or random.random() < np.exp(-delta / temp):
                current_penalty = new_penalty
            else:
                self.swap(index1, index2)  # Revert the swap

            temp *= cooling_rate

        return self.cube, current_penalty

# Usage
if __name__ == "__main__":
    cube_size = 5
    initial_temp = 1000
    cooling_rate = 0.99

    magic_cube = DiagonalMagicCube(cube_size)
    result, final_penalty = magic_cube.simulated_annealing(initial_temp, cooling_rate)

    print("Final Cube Configuration:")
    print(result)
    print("Final Penalty:", final_penalty)
