#include <iostream>
#include <fstream>
#include <pthread.h>
#include <queue>
#include <unistd.h>
#include <random>
#include <cstdlib>
#include <ctime>

// Queues for patients going to different specialists
std::queue<int> patientQueue;
std::queue<int> patientQueueDentist;
std::queue<int> patientQueueSurgeon;
std::queue<int> patientQueueTherapist;

// Counter for controlling the number of patients
int NUM_PATIENTS = 5;  // Default value
int NUM_CURED_PATIENTS = 0;

// Array of specialist names
std::string specialistNames[] = {"Dentist", "Surgeon", "Therapist"};

// Random number generator using std::mt19937
std::random_device rd;
std::mt19937 gen(rd());

// Mutexes for synchronization
pthread_mutex_t queueMutex = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t coutMutex = PTHREAD_MUTEX_INITIALIZER;

// Condition variables for synchronization
pthread_cond_t condvar = PTHREAD_COND_INITIALIZER;
pthread_cond_t specialistCondvar[3];  // One condition variable for each specialist
pthread_cond_t dutyDoctorCondvar[2];  // One condition variable for each duty doctor

// Output file for logging results
std::ofstream outFile;

// Function to log output to both console and file
void logOutput(const std::string& message) {
    std::cout << message << std::endl;
    if (outFile.is_open()) {
        outFile << message << std::endl;
    }
}

// Function to create a patient and add them to the general queue
void* PatientRoutine(void* arg) {
    std::uniform_int_distribution<int> dist(0, 1);
    int* patientId = new int(*(int*)arg);

    pthread_mutex_lock(&queueMutex);
    patientQueue.push(*patientId);
    pthread_cond_signal(&dutyDoctorCondvar[dist(gen)]); // Signal that a patient has arrived
    pthread_mutex_unlock(&queueMutex);

    delete patientId;
    return nullptr;
}

// Function for the duty doctor
void* dutyDoctor(void* arg) {
    int doctorId = *(int*)arg;
    int specialist;
    std::uniform_int_distribution<int> dist(0, 2);

    while (true) {
        pthread_mutex_lock(&queueMutex);
        while (patientQueue.empty()) {
            // Wait for a patient to appear
            pthread_cond_wait(&dutyDoctorCondvar[doctorId - 1], &queueMutex);
            if (NUM_CURED_PATIENTS == NUM_PATIENTS) {
                break;
            }
        }

        if (NUM_CURED_PATIENTS < NUM_PATIENTS) {
            int patientId = patientQueue.front();
            patientQueue.pop();

            specialist = dist(gen);
            std::string message = "Duty Doctor " + std::to_string(doctorId) + " sends Patient " + std::to_string(patientId)
                                  + " to " + specialistNames[specialist];
            logOutput(message);

            // Send the patient to the selected specialist
            switch (specialist) {
                case 0: patientQueueDentist.push(patientId); break;
                case 1: patientQueueSurgeon.push(patientId); break;
                case 2: patientQueueTherapist.push(patientId); break;
            }

            pthread_mutex_unlock(&queueMutex);

            pthread_cond_signal(&specialistCondvar[specialist]);  // Signal the specialist
            sleep(2);

            // Check if all patients have been cured
            pthread_mutex_lock(&queueMutex);
        }

        if (NUM_CURED_PATIENTS == NUM_PATIENTS) {
            // If all patients are cured, finish the work of the specialists and duty doctors
            if (specialist != 0) {
                pthread_cond_signal(&specialistCondvar[0]);
            }
            if (specialist != 1) {
                pthread_cond_signal(&specialistCondvar[1]);
            }
            if (specialist != 2) {
                pthread_cond_signal(&specialistCondvar[2]);
            }
            if (doctorId != 1) {
                pthread_cond_signal(&dutyDoctorCondvar[0]);
            }
            if (doctorId != 2) {
                pthread_cond_signal(&dutyDoctorCondvar[1]);
            }
            pthread_mutex_unlock(&queueMutex);
            break;
        }

        pthread_mutex_unlock(&queueMutex);
    }

    return nullptr;
}

// Function for the specialists (dentist, surgeon, therapist)
void* specialist(void* arg) {
    int specialistId = *(int*)arg;
    std::queue<int>* patientQueueToSpecialist = nullptr;

    switch (specialistId) {
        case 0: patientQueueToSpecialist = &patientQueueDentist; break;
        case 1: patientQueueToSpecialist = &patientQueueSurgeon; break;
        case 2: patientQueueToSpecialist = &patientQueueTherapist; break;
    }

    while (true) {
        pthread_mutex_lock(&queueMutex);
        while (patientQueueToSpecialist->empty() && NUM_CURED_PATIENTS != NUM_PATIENTS) {
            // Wait for a patient in the queue or for all patients to be cured
            pthread_cond_wait(&specialistCondvar[specialistId], &queueMutex);
        }

        // If all patients are cured, exit the loop
        if (NUM_CURED_PATIENTS == NUM_PATIENTS && patientQueueToSpecialist->empty()) {
            pthread_mutex_unlock(&queueMutex);
            break;
        }

        int patientId = patientQueueToSpecialist->front();
        patientQueueToSpecialist->pop();

        std::string message = specialistNames[specialistId] + " is treating Patient " + std::to_string(patientId);
        logOutput(message);

        pthread_mutex_unlock(&queueMutex);

        sleep(1);  // Simulate treatment time

        pthread_mutex_lock(&coutMutex);
        message = specialistNames[specialistId] + " has finished treating Patient " + std::to_string(patientId);
        logOutput(message);
        ++NUM_CURED_PATIENTS;
        pthread_mutex_unlock(&coutMutex);
    }
    return nullptr;
}

// Function to read the configuration file for the number of patients
void readConfigFile(const std::string& configFileName) {
    std::ifstream configFile(configFileName);
    if (configFile.is_open()) {
        configFile >> NUM_PATIENTS;
        if (NUM_PATIENTS <= 0) {
            std::cout << "Invalid number of patients in config file. Setting NUM_PATIENTS to default (5)." << std::endl;
            NUM_PATIENTS = 5;
        }
        configFile.close();
    } else {
        std::cout << "Failed to open config file." << std::endl;
    }
}

int main(int argc, char* argv[]) {
    std::string outputFileName = "output.txt";  // Default output file name
    std::string configFileName = "";

    if (argc == 1) {
        std::cout << "Please, enter NUMBER OF PATIENTS: ";
        std::cin >> NUM_PATIENTS;
        if (NUM_PATIENTS <= 0) {
            std::cerr << "Invalid number of patients. Setting NUM_PATIENTS to default (5)." << std::endl;
            NUM_PATIENTS = 5;
        }
    }

    if (argc > 1) {
        if (std::string(argv[1]) == "-f" && argc > 2) {
            configFileName = argv[2];
            readConfigFile(configFileName);  // Read configuration from the file
        } else if (argc > 1) {
            NUM_PATIENTS = std::atoi(argv[1]);
            if (NUM_PATIENTS <= 0) {
                std::cout << "Invalid number of patients. Setting NUM_PATIENTS to default (5)." << std::endl;
                NUM_PATIENTS = 5;
            }
        }

        if (argc > 2 && std::string(argv[argc - 2]) == "-o" && argc > 3) {
            outputFileName = argv[argc - 1];
        }
    }

    outFile.open(outputFileName, std::ios::out);
    if (!outFile.is_open()) {
        std::cout << "Failed to open output file." << std::endl;
        return 1;
    }

    std::cout << "Number of patients: " << NUM_PATIENTS << std::endl;

    pthread_t dutyDoctor1, dutyDoctor2, dentist, surgeon, therapist;
    pthread_t patientThreads[NUM_PATIENTS];

    int dutyDoctor1Id = 1, dutyDoctor2Id = 2;
    int dentistId = 0, surgeonId = 1, therapistId = 2;

    // Initialize condition variables for specialists and duty doctors
    for (int i = 0; i < 3; ++i) {
        pthread_cond_init(&specialistCondvar[i], nullptr);
    }
    for (int i = 0; i < 2; ++i) {
        pthread_cond_init(&dutyDoctorCondvar[i], nullptr);
    }

    // Create threads for patients
    for (int i = 0; i < NUM_PATIENTS; ++i) {
        int* id = new int(i);
        pthread_create(&patientThreads[i], nullptr, PatientRoutine, id);
    }

    // Wait for patient threads to finish
    for (int i = 0; i < NUM_PATIENTS; ++i) {
        pthread_join(patientThreads[i], nullptr);
    }

    // Create threads for duty doctors
    pthread_create(&dutyDoctor1, nullptr, dutyDoctor, &dutyDoctor1Id);
    pthread_create(&dutyDoctor2, nullptr, dutyDoctor, &dutyDoctor2Id);

    // Create threads for specialists
    pthread_create(&dentist, nullptr, specialist, &dentistId);
    pthread_create(&surgeon, nullptr, specialist, &surgeonId);
    pthread_create(&therapist, nullptr, specialist, &therapistId);

    // Wait for all threads to finish
    pthread_join(dutyDoctor1, nullptr);
    pthread_join(dutyDoctor2, nullptr);
    pthread_join(dentist, nullptr);
    pthread_join(surgeon, nullptr);
    pthread_join(therapist, nullptr);

    // Destroy condition variables
    for (int i = 0; i < 3; ++i) {
        pthread_cond_destroy(&specialistCondvar[i]);
    }
    for (int i = 0; i < 2; ++i) {
        pthread_cond_destroy(&dutyDoctorCondvar[i]);
    }

    outFile.close();

    std::cout << "_____END_OF_PROGRAM_____\n";
    return 0;
}
