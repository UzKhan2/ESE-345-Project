#include <iostream>
#include <string>
#include <fstream>
#include <sstream>
using namespace std;

string convert(string rd);
string convertnum(string num, int len);

int main()
{
	ifstream inputFile ("C:\\Users\\UZAIR\\Downloads\\instructions.txt");
	ofstream outputFile("C:\\Users\\UZAIR\\Downloads\\bininstructions.txt");
	string instr, rd, rs1, rs2, rs3, opcode;
	
	string line = "";
	while (getline(inputFile, line))
	{
		string tempString = "";
		stringstream inputString(line);

		getline(inputString, instr, ' ');
		line = "";
	/*------------------------------Load Immediate--------------------------*/
	if (instr == "LDI")
	   {
	   	opcode = "0";
	   	string li, im;
	   	getline(inputString, rd, ',');
		getline(inputString, li, ',');
	   	getline(inputString, im, ',');
	   	outputFile << opcode;
	   	outputFile << convertnum(li, 2);
	   	outputFile << convertnum(im, 15);
	   	outputFile << convert(rd) << endl;
	   }
	/*------------------------------R4 Instructions--------------------------*/
	else if (instr == "IAL")
	   {
	   	opcode = "10000";
		getline(inputString, rd, ',');
		getline(inputString, rs1, ',');
		getline(inputString, rs2, ',');
		getline(inputString, rs3, ',');
		outputFile << opcode;
		outputFile << convert(rs3);
		outputFile << convert(rs2);
		outputFile << convert(rs1);
		outputFile << convert(rd) << endl;
	   }
	else if (instr == "IAH")
	   {
	   	opcode = "10001";
		getline(inputString, rd, ',');
		getline(inputString, rs1, ',');
		getline(inputString, rs2, ',');
		getline(inputString, rs3, ',');
		outputFile << opcode;
		outputFile << convert(rs3);
		outputFile << convert(rs2);
		outputFile << convert(rs1);
		outputFile << convert(rd) << endl;
	   }
	else if (instr == "ISL")
	   {
	   	opcode = "10010";
		getline(inputString, rd, ',');
		getline(inputString, rs1, ',');
		getline(inputString, rs2, ',');
		getline(inputString, rs3, ',');
		outputFile << opcode;
		outputFile << convert(rs3);
		outputFile << convert(rs2);
		outputFile << convert(rs1);
		outputFile << convert(rd) << endl;
	   }
	else if (instr == "ISH")
	   {
	   	opcode = "10011";
		getline(inputString, rd, ',');
		getline(inputString, rs1, ',');
		getline(inputString, rs2, ',');
		getline(inputString, rs3, ',');
		outputFile << opcode;
		outputFile << convert(rs3);
		outputFile << convert(rs2);
		outputFile << convert(rs1);
		outputFile << convert(rd) << endl;
	   }
	else if (instr == "LAL")
	   {
	   	opcode = "10100";
		getline(inputString, rd, ',');
		getline(inputString, rs1, ',');
		getline(inputString, rs2, ',');
		getline(inputString, rs3, ',');
		outputFile << opcode;
		outputFile << convert(rs3);
		outputFile << convert(rs2);
		outputFile << convert(rs1);
		outputFile << convert(rd) << endl;
	   }
	else if (instr == "LAH")
	   {
	   	opcode = "10101";
		getline(inputString, rd, ',');
		getline(inputString, rs1, ',');
		getline(inputString, rs2, ',');
		getline(inputString, rs3, ',');
		outputFile << opcode;
		outputFile << convert(rs3);
		outputFile << convert(rs2);
		outputFile << convert(rs1);
		outputFile << convert(rd) << endl;
	   }
	else if (instr == "LSL")
	   {
	   	opcode = "10110";
		getline(inputString, rd, ',');
		getline(inputString, rs1, ',');
		getline(inputString, rs2, ',');
		getline(inputString, rs3, ',');
		outputFile << opcode;
		outputFile << convert(rs3);
		outputFile << convert(rs2);
		outputFile << convert(rs1);
		outputFile << convert(rd) << endl;
	   }
	else if (instr == "LSH")
	   {
	   	opcode = "10111";
		getline(inputString, rd, ',');
		getline(inputString, rs1, ',');
		getline(inputString, rs2, ',');
		getline(inputString, rs3, ',');
		outputFile << opcode;
		outputFile << convert(rs3);
		outputFile << convert(rs2);
		outputFile << convert(rs1);
		outputFile << convert(rd) << endl;
	   }
	/*------------------------------R3 Instructions--------------------------*/
	else if (instr == "NOP")
	   {
		string out = "1100000000000000000000000";
		outputFile << out << endl;
	   }
	else if (instr == "CLZW")
	   {
		opcode = "1100000001";
		getline(inputString, rd, ',');
		getline(inputString, rs1, ',');
		getline(inputString, rs2, ',');
		outputFile << opcode;
		outputFile << convert(rs2);
		outputFile << convert(rs1);
		outputFile << convert(rd) << endl;
	   }
	else if (instr == "AU")
	   {
		opcode = "1100000010";
		getline(inputString, rd, ',');
		getline(inputString, rs1, ',');
		getline(inputString, rs2, ',');
		outputFile << opcode;
		outputFile << convert(rs2);
		outputFile << convert(rs1);
		outputFile << convert(rd) << endl;
	   }
	else if (instr == "AHU")
	   {
	   	opcode = "1100000011";
		getline(inputString, rd, ',');
		getline(inputString, rs1, ',');
		getline(inputString, rs2, ',');
		outputFile << opcode;
		outputFile << convert(rs2);
		outputFile << convert(rs1);
		outputFile << convert(rd) << endl;	
	   }
	else if (instr == "AHS")
	   {
	   	opcode = "1100000100";
		getline(inputString, rd, ',');
		getline(inputString, rs1, ',');
		getline(inputString, rs2, ',');
		outputFile << opcode;
		outputFile << convert(rs2);
		outputFile << convert(rs1);
		outputFile << convert(rd) << endl;
	   }
	else if (instr == "AND")
	   {
	   	opcode = "1100000101";
		getline(inputString, rd, ',');
		getline(inputString, rs1, ',');
		getline(inputString, rs2, ',');
		outputFile << opcode;
		outputFile << convert(rs2);
		outputFile << convert(rs1);
		outputFile << convert(rd) << endl;
	   }
	else if (instr == "BCW")
	   {
	   	opcode = "1100000110";
		getline(inputString, rd, ',');
		getline(inputString, rs1, ',');
		getline(inputString, rs2, ',');
		outputFile << opcode;
		outputFile << convert(rs2);
		outputFile << convert(rs1);
		outputFile << convert(rd) << endl;
	   }
	else if (instr == "MAXWS")
	   {
	   	opcode = "1100000111";
		getline(inputString, rd, ',');
		getline(inputString, rs1, ',');
		getline(inputString, rs2, ',');
		outputFile << opcode;
		outputFile << convert(rs2);
		outputFile << convert(rs1);
		outputFile << convert(rd) << endl;
	   }
	else if (instr == "MINWS")
	   {
	   	opcode = "1100001000";
		getline(inputString, rd, ',');
		getline(inputString, rs1, ',');
		getline(inputString, rs2, ',');
		outputFile << opcode;
		outputFile << convert(rs2);
		outputFile << convert(rs1);
		outputFile << convert(rd) << endl;
	   }
	else if (instr == "MLHU")
	   {
	   	opcode = "1100001001";
		getline(inputString, rd, ',');
		getline(inputString, rs1, ',');
		getline(inputString, rs2, ',');
		outputFile << opcode;
		outputFile << convert(rs2);
		outputFile << convert(rs1);
		outputFile << convert(rd) << endl;
	   }
	else if (instr == "MLHCU")
	   {
	   	opcode = "1100001010";
		getline(inputString, rd, ',');
		getline(inputString, rs1, ',');
		getline(inputString, rs2, ',');
		outputFile << opcode;
		outputFile << convert(rs2);
		outputFile << convert(rs1);
		outputFile << convert(rd) << endl;
	   }
	else if (instr == "OR")
	   {
	   	opcode = "1100001011";
		getline(inputString, rd, ',');
		getline(inputString, rs1, ',');
		getline(inputString, rs2, ',');
		outputFile << opcode;
		outputFile << convert(rs2);
		outputFile << convert(rs1);
		outputFile << convert(rd) << endl;
	   }
	else if (instr == "PCNTW")
	   {
	   	opcode = "1100001100";
		getline(inputString, rd, ',');
		getline(inputString, rs1, ',');
		getline(inputString, rs2, ',');
		outputFile << opcode;
		outputFile << convert(rs2);
		outputFile << convert(rs1);
		outputFile << convert(rd) << endl;
	   }
	else if (instr == "ROTW")
	   {
	   	opcode = "1100001101";
		getline(inputString, rd, ',');
		getline(inputString, rs1, ',');
		getline(inputString, rs2, ',');
		outputFile << opcode;
		outputFile << convert(rs2);
		outputFile << convert(rs1);
		outputFile << convert(rd) << endl;
		}
	else if (instr == "SFWU")
	   	{
	   	opcode = "1100001110";
		getline(inputString, rd, ',');
		getline(inputString, rs1, ',');
		getline(inputString, rs2, ',');
		outputFile << opcode;
		outputFile << convert(rs2);
		outputFile << convert(rs1);
		outputFile << convert(rd) << endl;
	   	}
	else if (instr == "SFHS")
	   	{
	   	opcode = "1100001111";
		getline(inputString, rd, ',');
		getline(inputString, rs1, ',');
		getline(inputString, rs2, ',');
		outputFile << opcode;
		outputFile << convert(rs2);
		outputFile << convert(rs1);
		outputFile << convert(rd) << endl;
		}
	else 
	{
		outputFile << "ERROR TRANSLATING";	
	}
	}
return 0;
}

string convert(string rd)
{
	int pos = rd.find("$");	
	string sub = rd.substr(pos + 1);
	int value = stoi(sub);
	
	string one ="1";
	string zero = "0";
	string output ="";
	if (value > 31 || value < 0)
	{
		output = "ERROR";
		return output;
	}
	for (int i = 4; i >= 0; i--)
	{
        int k = value >> i;
        if (k & 1)
        {
    		output.append(one);
    	}
        else
        {
            output.append(zero);
        }
    }
return output;	
}

string convertnum(string num, int len)
{
	string sub = num.substr(0);
	int value = stoi(sub);
	string one ="1";
	string zero = "0";
	string output ="";
	for (int i = len; i >= 0; i--)
	{
        int k = value >> i;
        if (k & 1)
        {
    		output.append(one);
    	}
        else
        {
            output.append(zero);
        }
    }
return output;	
}
