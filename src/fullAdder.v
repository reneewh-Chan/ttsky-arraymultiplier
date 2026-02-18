module bit16_Adder(A, B, Cout, S);
  input [15:0] A, B; 
  output reg Cout;
  output reg [15:0] S;
  wire Cin;
  assign Cin = 0;

  reg [16:0] C; // stores each carry made by each operation

  integer k;
  always @ (*)
  begin
    C[0] = Cin;
    for (k = 0; k < 16; k = k + 1)
      begin
        S[k] = A[k] ^ B[k] ^ C[k]; // the sum is made from XOR of each input
        if (A[k] == B[k]) // carrying the cin -> cout logic
          C[k + 1] = A[k]; 
        else 
          C[k + 1] = C[k];
      end
    Cout = C[k]; // 17th bit
  end
  
endmodule
