import { Module } from '@nestjs/common';
import { TokenController } from './token.controller';
import { TokenService } from './token.service';
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
  controllers: [TokenController],
  providers: [TokenService],
})
export class TokenModule {}
