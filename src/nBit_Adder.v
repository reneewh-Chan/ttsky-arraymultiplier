module bit16_Adder #(parameter N = 16)( // maybe will need a 16 and 17 to add the 3 products at the end
  input [N-1:0] A, B,
  output reg Cout,
  output reg [N-1:0] S
);
  
  wire Cin;
  assign Cin = 0;
  reg [N:0] C; // stores each carry made by each operation

  integer k;
  always @ (*)
  begin
    C[0] = Cin;
    for (k = 0; k < N; k = k + 1)
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
