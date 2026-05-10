import { Body, Controller, Get, Post, Query } from '@nestjs/common';
import { BlockchainService } from './../blockchain/blockchain.service';

import { parseEther } from 'viem';
import { MINER_MANAGER_ABI } from 'src/blockchain/abis/minerManager.abi';

import { UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from './../auth/jwt.guard';
import { MinerService } from './miner.service';

const MINER_MANAGER_ADDRESS = '0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9';

@UseGuards(JwtAuthGuard)
@Controller('miner')
export class MinerController {
  constructor(
    private readonly blockchainService: BlockchainService,
    private minerService: MinerService,
  ) {}

  @Get()
  getMiner(): string {
    return 'Hello Miner!';
  }

  @Post('buy-tokens')
  async buyTokens(
    @Body() body: { privateKey: `0x${string}`; ethAmount: string },
  ) {
    return this.minerService.buyTokens(body.ethAmount, body.privateKey);
  }

  @Get('getBalanceof')
  async getBalance(@Query('address') address: `0x${string}`) {
    return this.minerService.getBalanceOf(address);
  }

  @Post('buy-miner')
  async buyMiner(
    @Body() body: { privateKey: `0x${string}`; quantity: number },
  ) {
    return this.minerService.buyMiner(body.quantity, body.privateKey);
  }
}
