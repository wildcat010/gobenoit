import { Body, Controller, Get, Post } from '@nestjs/common';
import { BlockchainService } from './../blockchain/blockchain.service';
import { GBN_TOKEN_ABI } from './../blockchain/abis/GBNToken.abi';
import { formatUnits } from 'viem';

import { UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from './../auth/jwt.guard';
import { TokenService } from './token.service';

const GBN_TOKEN_ADDRESS = '0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512'; // your GBNToken proxy
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
    const totalSupply = await this.blockchainService
      .getPublicClient()
      .readContract({
        address: GBN_TOKEN_ADDRESS,
        abi: GBN_TOKEN_ABI,
        functionName: 'totalSupply',
      });

    // returns human-readable GBN amount (divides by 1e18)
    return formatUnits(totalSupply, 18);
  }

  @Post('pause')
  async pause(@Body() body: { pause: boolean; privateKey: `0x${string}` }) {
    return this.tokenService.pause(body.pause, body.privateKey);
  }
}
