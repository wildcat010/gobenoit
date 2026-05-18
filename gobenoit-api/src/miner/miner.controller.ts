import { Body, Controller, Get, Post, Query } from '@nestjs/common';
import { BlockchainService } from './../blockchain/blockchain.service';

import { UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from './../auth/jwt.guard';
import { MinerService } from './miner.service';

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

  @Post('claim-reward')
  async claim(@Body() body: { privateKey: `0x${string}` }) {
    return this.minerService.claim(body.privateKey);
  }

  @Post('pending-reward')
  async pendingReward(@Body() body: { address: `0x${string}` }) {
    return this.minerService.pendingReward(body.address);
  }

  @Post('pause')
  async pause(@Body() body: { pause: boolean; privateKey: `0x${string}` }) {
    return this.minerService.pause(body.pause, body.privateKey);
  }

  @Get('miners-list')
  async minersList() {
    return this.minerService.getMinersList();
  }
}
