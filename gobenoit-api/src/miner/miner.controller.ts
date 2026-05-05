import { Body, Controller, Get, Post } from '@nestjs/common';
import { BlockchainService } from './../blockchain/blockchain.service';

import { parseEther } from 'viem';
import { MINER_MANAGER_ABI } from 'src/blockchain/abis/minerManager.abi';

const MINER_MANAGER_ADDRESS = '0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9';

@Controller('miner')
export class MinerController {
  constructor(private readonly blockchainService: BlockchainService) {}

  @Get()
  getMiner(): string {
    return 'Hello Miner!';
  }

  @Post('buy-tokens')
  async buyTokens(
    @Body() body: { privateKey: `0x${string}`; ethAmount: string },
  ) {
    const walletClient = this.blockchainService.getWalletClient(
      body.privateKey,
    );

    const txHash = await walletClient.writeContract({
      address: MINER_MANAGER_ADDRESS,
      abi: MINER_MANAGER_ABI,
      functionName: 'buyTokens',
      value: parseEther(body.ethAmount), // e.g. "0.1"
    });

    const receipt =
      await this.blockchainService.client.waitForTransactionReceipt({
        hash: txHash,
      });

    return {
      txHash,
      status: receipt.status, // "success" or "reverted"
      blockNumber: receipt.blockNumber.toString(),
    };
  }
}
