export const MINER_MANAGER_ABI = [
  {
    name: 'buyTokens',
    type: 'function',
    stateMutability: 'payable',
    inputs: [],
    outputs: [],
  },
  {
    name: 'buyMiner',
    type: 'function',
    stateMutability: 'nonpayable',
    inputs: [{ name: 'quantity', type: 'uint256' }],
    outputs: [],
  },
] as const;
