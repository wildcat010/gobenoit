import { Body, Controller, Get, Post } from '@nestjs/common';
import { BlockchainService } from './../blockchain/blockchain.service';

import { UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from './../auth/jwt.guard';
import { TokenService } from './token.service';

@UseGuards(JwtAuthGuard)
@Controller('token')
export class TokenController {
  constructor(
    private readonly blockchainService: BlockchainService,
    private tokenService: TokenService,
  ) {}

  @Get()
  getToken(): string {
    return 'Hello Token!';
  }

  @Get('total-supply')
  async getTotalSupply(): Promise<string> {
    return this.tokenService.getTotalSupply();
  }

  @Post('pause')
  async pause(@Body() body: { pause: boolean; privateKey: `0x${string}` }) {
    return this.tokenService.pause(body.pause, body.privateKey);
  }
}
