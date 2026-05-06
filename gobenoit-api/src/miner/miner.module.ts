import { Module } from '@nestjs/common';
import { MinerController } from './miner.controller';
import { MinerService } from './miner.service';
import { BlockchainModule } from 'src/blockchain/blockchain.module';

@Module({
  imports: [BlockchainModule],
  controllers: [MinerController],
  providers: [MinerService],
})
export class MinerModule {}
