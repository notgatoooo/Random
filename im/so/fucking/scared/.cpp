// luau ahh copy :p
// made by gato

#include <iostream>
#include <fstream>
#include <filesystem>
#include <ctime>
#include <iomanip>
#include <sstream>
#include <cstdlib>
#include <vector>
#include <thread>
#include <chrono>
#include <cmath>

using namespace std;

#define hasdbg
// for debugging

namespace gss {
    void waitfor(double s) {
        #ifdef hasdbg
        	cout << "wait " << s << "s..." << endl; // no print cuz out of scope :D
        #endif
        if (s <= 0) {
            return;
        } else {
            int n = s*1000;
            this_thread::sleep_for(chrono::milliseconds(n));
        }
    }

    // vro i had to create ts cuz getting time is a pain in the ass
    string gettime(string typething) {
        auto temp = chrono::system_clock::now();
        time_t rn =  chrono::system_clock::to_time_t(temp);
        tm* localg = localtime(&rn);

        ostringstream cpp_is_a_bitch_idk_why_i_need_to_do_all_this;
        cpp_is_a_bitch_idk_why_i_need_to_do_all_this << put_time(localg, typething.c_str());

        return cpp_is_a_bitch_idk_why_i_need_to_do_all_this.str();
    }

    namespace input {
        template<typename p>
        void print(const p& msg) {
            cout << "[" << gettime("%Y:%M:%H:%M:%S") << "] [OUTPUT] " << msg << endl;
        }

        template<typename w>
        void warn(const w& msg) {
            cout << "\033[33m" << "[" << gettime("%Y:%M:%H:%M:%S") << "] [WARNING] " << msg << "\033[37m" << endl;
        }
        
        template<typename e>
        void error(const e& msg) {
            cout << "\033[31m" << "[" << gettime("%Y:%M:%H:%M:%S") << "] [ERROR] " << msg << "\033[37m" << endl;
            exit(1);
        }
    }

    namespace io {
        void writefile(string path, string contents) {
            #ifdef hasdbg
        		cout << "yo write file " << path << " has: " << contents << endl;
        	#endif
            ofstream file(path);

            file << contents;
            file.close();
            #ifdef hasdbg
        		cout << "ok wrote file" << endl;
        	#endif
        }

        void writedir(string path) {
            #ifdef hasdbg
        		cout << "yo write dir at " << path << endl;
        	#endif
            if (not filesystem::exists(path)) {
                #ifdef hasdbg
        			cout << "wrote dir" << endl;
        		#endif
                filesystem::create_directories(path);
            }
        }

        void deldir(string path) {
            #ifdef hasdbg
        		cout << "yo del dir " << path << endl;
        	#endif
            if (filesystem::exists(path) && filesystem::is_directory(path)) {
                #ifdef hasdbg
        			cout << "deleted dir ok";
        		#endif
                filesystem::remove_all(path);
            }
        }

        void delfile(string path) {
            #ifdef hasdbg
        		cout << "yo del file at " << path << endl;
        	#endif
            if (filesystem::exists(path) && not filesystem::is_directory(path)) {
                #ifdef hasdbg
        			cout << "done boss deleted dat file" << endl;
        		#endif
                filesystem::remove(path);
            } else {
                gss::input::error("File doesnt exist...");
            }
        }

        void appendtofile(string path, string contents) {
            #ifdef hasdbg
        		cout << "yo append to file " << path << " content: " << contents << endl;
        	#endif
            if (filesystem::exists(path) && not filesystem::is_directory(path)) {
                #ifdef hasdbg
        			cout << "sucess wrote " << contents << " for " << path << ":)" << contents << endl;
        		#endif
                // fixed ts so its moderner :D
                ofstream file(path, ios::app);

                file << contents;
                file.close();
            } else {
                gss::input::error("File doesnt exist...");
            }
        }
        // todo: optimize isfile and isfolder tobe 1 line

        bool isafile(string path) {
            return filesystem::exists(path) && not filesystem::is_directory(path);
        }

        bool isadir(string path) {
            return filesystem::exists(path) && filesystem::is_directory(path);
        }

        vector<string> listdirs(string path, bool recursive) {
            #ifdef hasdbg
        		cout << "list dirs for " << path << endl;
        	#endif
            vector<string> stuff = {};

            if (filesystem::exists(path) && filesystem::is_directory(path)) {
                if (recursive) {
                    for (const auto& entry : filesystem::recursive_directory_iterator(path)) {
                        #ifdef hasdbg
        					cout << path << " has dir: " << entry.path().string() << endl;
        				#endif
                        stuff.emplace_back(entry.path().string());
                    }
                } else {
                    for (const auto& entry : filesystem::directory_iterator(path)) {
                        #ifdef hasdbg
        					cout << path << " has dir: " << entry.path().string() << endl;
        				#endif
                        stuff.emplace_back(entry.path().string());
                    }
                }

                return stuff;
            } else {
                // idk i should return a message but fuck it
                gss::input::error("File doesnt exist...");
                return {};
            }
        }

        string readfile(string path) {
            #ifdef hasdbg
        		cout << "reading filw: " << path << endl;
        	#endif
            if (filesystem::exists(path) && not filesystem::is_directory(path)) {
                ifstream file(path);

                string txt;
                getline(file, txt, '\0');
                file.close();
                #ifdef hasdbg
        			cout << "result as: " << txt << endl;
        		#endif
                return txt;
            } else {
                gss::input::error("File doesnt exist...");
                return "";
            }
        }
    }

    // already hate this tbh
    namespace math {
        int rng(int max) {
            srand(time(nullptr));

            if (max <= 0) {
                int num = rand();
                return num;
            } else {
                int num = rand() & max;
                return num;
            }
        }

        double factorial(int n) {
            double res = n;

            if (res == 0) {
                gss::input::error("Cannot Factorial by 0!!!!1");
                return 0.0;
            }

            if (res < 0) {
                res = -res;
            }
            
            double backup = n -= 1;
            for (int i = 0; i < n; i++) {
                res *= backup;
                backup -= 1;
            }

            return res;
        }

        double powerof(int n, int np) {
            long long exp = np;
            double res = 1.0;

            if (exp < 0) {
                exp = -exp;
            }

            for (int i = 0; i < exp; i++) {
                res *= n;
            }

            if (n == 0 && np <= 0) {
                gss::input::error("Cannot divide by 0!!!!");
                return 0.0;
            }

            if (np < 0) {
                return 1.0 / res;
            }

            return res;
        }
    }

    namespace threader{
        template <class F>
        void thread(F&& f) {
            #ifdef hasdbg
        		cout << "creating thread..." << endl;
        	#endif
            thread(forward<F>(f)).detach();
        }

        template <class F>
        void thread_wait(double s, F&& f) {
            #ifdef hasdbg
        		cout << "waiting to thread..." << endl;
        	#endif
            thread([s, func = forward<F>(f)]() mutable{
                gss::waitfor(s);
                #ifdef hasdbg
        			cout << "created thread." << endl;
        		#endif
                func();
            }).detach();
        }
    }

    auto cwd() {
        return filesystem::current_path();
    }

    string indent() {
        return "Gato Space Language (C++ 20+)";
    }
}
