import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { ConfigModule } from '@nestjs/config';

import { AppService } from './app.service';

import { AuthService } from './auth.service';
import { UsersModule } from './users/users.module';
import { MinerModule } from './miner/miner.module';
import { TokenModule } from './token/token.module';
import { BlockchainModule } from './blockchain/blockchain.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),

    MongooseModule.forRoot(process.env.MONGO_URI!),

    MinerModule,
    TokenModule,
    UsersModule,
    BlockchainModule,
  ],
  providers: [AppService, AuthService],
})
export class AppModule {}
