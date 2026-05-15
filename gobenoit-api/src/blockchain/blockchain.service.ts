import { Injectable } from '@nestjs/common';
import { createPublicClient, createWalletClient, http } from 'viem';
import { privateKeyToAccount } from 'viem/accounts';
//debug -- import { anvil } from 'viem/chains';
import { sepolia } from 'viem/chains';

@Injectable()
export class BlockchainService {
  private getRpcUrl() {
    const url = process.env.SEPOLIA_RPC_URL;
    console.log('RPC URL:', url);
    if (!url) {
      throw new Error('SEPOLIA_RPC_URL is missing');
    }

    return url;
  }

  getPublicClient() {
    return createPublicClient({
      chain: sepolia,
      transport: http(this.getRpcUrl()),
    });
  }

  getWalletClient(privateKey: `0x${string}`) {
    console.log('RPC URL:', this.getRpcUrl());
    const account = privateKeyToAccount(privateKey);
    return createWalletClient({
      account,
      chain: sepolia, //chain: anvil, --debug
      transport: http(this.getRpcUrl()),
    });
  }
}
