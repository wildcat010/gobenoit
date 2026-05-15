import { Injectable } from '@nestjs/common';
import { BlockchainService } from '../blockchain/blockchain.service';
import { GBN_TOKEN_ABI } from '../blockchain/abis/GBNToken.abi';
import { formatUnits } from 'viem';

const GBN_TOKEN_ADDRESS = '0xf55E06513D31acF95C27e30C019AC3cfd934fF0C';

@Injectable()
export class TokenService {
  constructor(private readonly blockchainService: BlockchainService) {}

  async getTotalSupply(): Promise<string> {
    const totalSupply = await this.blockchainService
      .getPublicClient()
      .readContract({
        address: GBN_TOKEN_ADDRESS,
        abi: GBN_TOKEN_ABI,
        functionName: 'totalSupply',
      });

    return formatUnits(totalSupply, 18);
  }

  async pause(pause: boolean, privateKey: `0x${string}`) {
    const walletClient = this.blockchainService.getWalletClient(privateKey);

    const txHash = await walletClient.writeContract({
      address: GBN_TOKEN_ADDRESS,
      abi: GBN_TOKEN_ABI,
      functionName: pause ? 'pause' : 'unpause',
    });

    const receipt = await this.blockchainService
      .getPublicClient()
      .waitForTransactionReceipt({
        hash: txHash,
      });

    return {
      txHash,
      paused: pause,
      status: receipt.status,
    };
  }
}
