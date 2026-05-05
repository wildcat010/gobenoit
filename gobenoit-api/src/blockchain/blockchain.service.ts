import { Injectable } from '@nestjs/common';
import { createPublicClient, createWalletClient, http } from 'viem';
import { privateKeyToAccount } from 'viem/accounts';
import { anvil } from 'viem/chains';

@Injectable()
export class BlockchainService {
  public readonly client = createPublicClient({
    chain: anvil,
    transport: http('http://127.0.0.1:8545'),
  });

  getWalletClient(privateKey: `0x${string}`) {
    const account = privateKeyToAccount(privateKey);
    return createWalletClient({
      account,
      chain: anvil,
      transport: http('http://127.0.0.1:8545'),
    });
  }
}
