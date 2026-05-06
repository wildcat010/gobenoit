import { Injectable } from '@nestjs/common';
import { BlockchainService } from '../blockchain/blockchain.service';
import { MINER_MANAGER_ABI } from 'src/blockchain/abis/minerManager.abi';
import { parseEther } from 'viem';

const MINER_MANAGER_ADDRESS = '0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9';

@Injectable()
export class MinerService {
  constructor(private readonly blockchainService: BlockchainService) {}

  async buyTokens(ethAmount: string) {
    if (!ethAmount) {
      throw new Error('ethAmount is required');
    }

    const walletClient = this.blockchainService.getWalletClient(
      process.env.PRIVATE_KEY as `0x${string}`,
    );

    const txHash = await walletClient.writeContract({
      address: MINER_MANAGER_ADDRESS,
      abi: MINER_MANAGER_ABI,
      functionName: 'buyTokens',
      value: parseEther(ethAmount),
    });

    return { txHash };
  }
}
