#include <iostream>
#include <fstream>
#include <pthread.h>
#include <queue>
#include <unistd.h>
#include <random>
#include <cstdlib>  // For rand() and srand(), atoi()
#include <ctime>    // For time()

// Queues for patients going to different specialists
std::queue<int> patientQueue;
std::queue<int> patientQueueDentist;
std::queue<int> patientQueueSurgeon;
std::queue<int> patientQueueTherapist;

// Counters for controlling the number of patients
int NUM_PATIENTS = 5;  // Default value
int NUM_CURED_PATIENTS = 0;

// Array of specialist names
std::string specialistNames[] = {"Dentist", "Surgeon", "Therapist"};

// Random number generator using std::mt19937
std::random_device rd;  // Random number source from hardware
std::mt19937 gen(rd()); // Initializing the generator based on random data

// Mutexes for synchronization
pthread_mutex_t queueMutex = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t coutMutex = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t finishMutex = PTHREAD_MUTEX_INITIALIZER;

std::ofstream outFile;  // Output file for results

// Function to log output to both console and file
void logOutput(const std::string& message) {
    // Output to the console
    std::cout << message << std::endl;
    // Write to the file
    if (outFile.is_open()) {
        outFile << message << std::endl;
    }
}

// Function to create a patient and add them to the general queue
void* PatientRoutine(void* arg) {
    int* patientId = new int(*(int*)arg);

    pthread_mutex_lock(&queueMutex);  // Locking the shared queue
    patientQueue.push(*patientId);
    pthread_mutex_unlock(&queueMutex);

    delete patientId;  // Free memory
    return nullptr;
}

// Function for the duty doctor, who sends patients to specialists
void* dutyDoctor(void* arg) {
    int doctorId = *(int*)arg;
    std::uniform_int_distribution<int> dist(0, 2);  // Distribution for selecting a specialist

    while (true) {
        pthread_mutex_lock(&queueMutex);  // Locking the shared queue

        if (!patientQueue.empty()) {
            pthread_mutex_lock(&coutMutex);  // Locking for console output

            int patientId = patientQueue.front();
            patientQueue.pop();

            // Sending the patient to a specialist (dentist, surgeon, or therapist)
            int specialist = dist(gen);  // 0 - dentist, 1 - surgeon, 2 - therapist
            std::string message = "Duty Doctor " + std::to_string(doctorId) + " sends Patient " + std::to_string(patientId)
                                  + " to " + specialistNames[specialist];
            logOutput(message);

            pthread_mutex_unlock(&coutMutex);  // Unlocking console output

            sleep(1);  // Simulating delay

            // Adding the patient to the respective specialist's queue
            switch (specialist) {
                case 0: patientQueueDentist.push(patientId); break;
                case 1: patientQueueSurgeon.push(patientId); break;
                case 2: patientQueueTherapist.push(patientId); break;
            }

            pthread_mutex_unlock(&queueMutex);  // Unlocking the queue
        } else {
            pthread_mutex_lock(&finishMutex);  // Checking if all work is done
            if (patientQueue.empty() && NUM_CURED_PATIENTS == NUM_PATIENTS) {
                pthread_mutex_unlock(&finishMutex);
                pthread_mutex_unlock(&queueMutex);
                break;  // All patients are served
            }
            pthread_mutex_unlock(&finishMutex);
            pthread_mutex_unlock(&queueMutex);
        }
    }
    return nullptr;
}

// Function for specialists (dentist, surgeon, therapist)
void* specialist(void* arg) {
    int specialistId = *(int*)arg;
    std::queue<int>* patientQueueToSpecialist = nullptr;

    // Determine which queue is used for the specialist
    switch (specialistId) {
        case 0: patientQueueToSpecialist = &patientQueueDentist; break;
        case 1: patientQueueToSpecialist = &patientQueueSurgeon; break;
        case 2: patientQueueToSpecialist = &patientQueueTherapist; break;
    }

    while (true) {
        if (!patientQueueToSpecialist->empty()) {
            pthread_mutex_lock(&queueMutex);  // Locking the specialist's queue

            int patientId = patientQueueToSpecialist->front();
            patientQueueToSpecialist->pop();

            // Treating the patient
            pthread_mutex_lock(&coutMutex);  // Locking for console output
            std::string message = specialistNames[specialistId] + " is treating Patient " + std::to_string(patientId);
            logOutput(message);

            pthread_mutex_unlock(&coutMutex);  // Unlocking console output

            pthread_mutex_unlock(&queueMutex);  // Unlocking the queue
            // Simulating patient treatment
            sleep(1);  // Treatment time

            pthread_mutex_lock(&coutMutex);  // Locking for console output
            message = specialistNames[specialistId] + " has finished treating Patient " + std::to_string(patientId);
            logOutput(message);
            ++NUM_CURED_PATIENTS;
            pthread_mutex_unlock(&coutMutex);
        } else {
            pthread_mutex_lock(&finishMutex);  // Checking if all work is done
            if (patientQueue.empty() && NUM_CURED_PATIENTS == NUM_PATIENTS) {
                pthread_mutex_unlock(&finishMutex);
                break;  // All patients are served
            }
            pthread_mutex_unlock(&finishMutex);
        }
    }
    return nullptr;
}

// Function to read the number of patients from the configuration file
void readConfigFile(const std::string& configFileName) {
    std::ifstream configFile(configFileName);
    if (configFile.is_open()) {
        configFile >> NUM_PATIENTS;  // Read the number of patients from the file
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
        // Checking for the configuration file
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

        // Checking for output file name
        if (argc > 2 && std::string(argv[argc - 2]) == "-o" && argc > 3) {
            outputFileName = argv[argc - 1];  // Output file name
        }
    }

    // Opening the file for logging results
    outFile.open(outputFileName, std::ios::out);
    if (!outFile.is_open()) {
        std::cout << "Failed to open output file." << std::endl;
        return 1;
    }

    std::cout << "Number of patients: " << NUM_PATIENTS << std::endl;

    // Array of threads for patients and doctors
    pthread_t dutyDoctor1, dutyDoctor2, dentist, surgeon, therapist;
    pthread_t patientThreads[NUM_PATIENTS];

    // Doctors' IDs
    int dutyDoctor1Id = 1, dutyDoctor2Id = 2;
    int dentistId = 0, surgeonId = 1, therapistId = 2;

    // Creating threads for patients
    for (int i = 0; i < NUM_PATIENTS; ++i) {
        int* id = new int(i);  // Creating a new object and passing it to the thread
        pthread_create(&patientThreads[i], nullptr, PatientRoutine, id);
    }

    // Waiting for patient threads to finish
    for (int i = 0; i < NUM_PATIENTS; ++i) {
        pthread_join(patientThreads[i], nullptr);
    }

    // Creating threads for duty doctors
    pthread_create(&dutyDoctor1, nullptr, dutyDoctor, &dutyDoctor1Id);
    pthread_create(&dutyDoctor2, nullptr, dutyDoctor, &dutyDoctor2Id);

    // Creating threads for specialists
    pthread_create(&dentist, nullptr, specialist, &dentistId);
    pthread_create(&surgeon, nullptr, specialist, &surgeonId);
    pthread_create(&therapist, nullptr, specialist, &therapistId);

    // Waiting for all threads to finish
    pthread_join(dutyDoctor1, nullptr);
    pthread_join(dutyDoctor2, nullptr);
    pthread_join(dentist, nullptr);
    pthread_join(surgeon, nullptr);
    pthread_join(therapist, nullptr);

    // Closing the output file
    outFile.close();

    std::cout << "_____END_OF_PROGRAM_____\n";
    return 0;
}
