import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { MinerController } from './miner/miner.controller';
import { BlockchainService } from './blockchain/blockchain.service';
import { TokenController } from './token/token.controller';

@Module({
  imports: [],
  controllers: [AppController, MinerController, TokenController],
  providers: [AppService, BlockchainService],
})
export class AppModule {}
