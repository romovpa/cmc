#include <fstream>

using namespace std;

int main() {
	ofstream out("input.txt");
	for (int i = 0; i < 1000000; i++)
		out << i % 30+1 << ".2.3" << endl;
	out.close();
}
