#include <iostream>
#include <cmath>   // For fabs() function

// Reference value of Pi
float reference = 3.141592653589793;

// Function to compute Pi using Nilakantha series
std::pair<float, float> computePi(float accuracy) {
    accuracy /= 100;  // Convert accuracy from percentage to decimal
    float pi = 3.0f;  // Initial value of pi
    int i = 1;         // Index for the series
    int sign = 1;      // Variable to alternate signs (+ or -)
    float current_accuracy = (fabs(reference - pi) / reference);  // Initial accuracy
    
    // Loop until the computed value is within the desired accuracy
    while (current_accuracy > accuracy) {

        // Compute the next term in the Nilakantha series
        float term = 4.0f / (2 * i * (2 * i + 1) * (2 * i + 2)); 

        // Add or subtract the term based on the current sign
        if (sign == 1) {
            pi += term;  // Add term if sign is positive
        } else {
            pi -= term;  // Subtract term if sign is negative
        }
        
        // Increment the index and alternate the sign
        i++;
        sign = -sign;  // Alternate the sign between positive and negative
        
        // Recalculate the current accuracy
        current_accuracy = (fabs(reference - pi) / reference);
    }

    // Return computed Pi value and accuracy as a pair
    return std::make_pair(pi, current_accuracy * 100);
}

int main() {
    // Test 1: accuracy = 0.05%, expected Pi value ~ 3.1427128
    float accuracy1 = 0.05;
    float expected1 = 3.1427128;

    // Test 2: accuracy = 0.005%, expected Pi value ~ 3.141736
    float accuracy2 = 0.005;
    float expected2 = 3.141736;

    // Test 3: accuracy = 0.00001%, expected Pi value ~ 3.1415925
    float accuracy3 = 0.00001;
    float expected3 = 3.1415925;

    // Compute Pi for each test case
    std::pair<float, float> result1 = computePi(accuracy1);
    std::pair<float, float> result2 = computePi(accuracy2);
    std::pair<float, float> result3 = computePi(accuracy3);

    // Output the results for each test case
    std::cout << "Test №1\n"
              << "Expected pi value: " << expected1 << "\n"
              << "Expected accuracy: " << accuracy1 << "\n"
              << "Computed pi value: " << result1.first << "\n"
              << "Computed accuracy (%): " << result1.second << "\n\n";

    std::cout << "Test №2\n"
              << "Expected pi value: " << expected2 << "\n"
              << "Expected accuracy: " << accuracy2 << "\n"
              << "Computed pi value: " << result2.first << "\n"
              << "Computed accuracy (%): " << result2.second << "\n\n";

    std::cout << "Test №3\n"
              << "Expected pi value: " << expected3 << "\n"
              << "Expected accuracy: " << accuracy3 << "\n"
              << "Computed pi value: " << result3.first << "\n"
              << "Computed accuracy (%): " << result3.second << "\n\n";
    
    return 0;
}
