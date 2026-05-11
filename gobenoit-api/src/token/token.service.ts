import { Injectable } from '@nestjs/common';
import { BlockchainService } from '../blockchain/blockchain.service';
import { GBN_TOKEN_ABI } from '../blockchain/abis/GBNToken.abi';
import { formatUnits } from 'viem';

const GBN_TOKEN_ADDRESS = '0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512';

@Injectable()
export class TokenService {
  constructor(private readonly blockchainService: BlockchainService) {}

  async getTotalSupply(): Promise<string> {
    const totalSupply = await this.blockchainService.client.readContract({
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
      functionName: pause ? 'pause' : 'unpause', // 👈 cleaner
    });

    const receipt =
      await this.blockchainService.client.waitForTransactionReceipt({
        hash: txHash,
      });

    return {
      txHash,
      paused: pause,
      status: receipt.status,
    };
  }
}
