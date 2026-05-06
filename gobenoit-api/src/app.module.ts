import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { ConfigModule } from '@nestjs/config';

import { AppController } from './app.controller';
import { AppService } from './app.service';
import { MinerController } from './miner/miner.controller';
import { BlockchainService } from './blockchain/blockchain.service';
import { TokenController } from './token/token.controller';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),

    MongooseModule.forRoot(process.env.MONGO_URI!),
  ],
  controllers: [AppController, MinerController, TokenController],
  providers: [AppService, BlockchainService],
})
export class AppModule {}
