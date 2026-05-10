import { Module } from '@nestjs/common';
import { MinerController } from './miner.controller';
import { MinerService } from './miner.service';
import { BlockchainModule } from 'src/blockchain/blockchain.module';

import { JwtModule } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config/dist/config.service';
import { ConfigModule } from '@nestjs/config/dist/config.module';

@Module({
  imports: [
    BlockchainModule,
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        secret: config.get<string>('JWT_SECRET'),
        signOptions: { expiresIn: '3h' },
      }),
    }),
  ],
  controllers: [MinerController],
  providers: [MinerService],
})
export class MinerModule {}
