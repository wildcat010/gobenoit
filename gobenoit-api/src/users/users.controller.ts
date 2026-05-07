// users/users.controller.ts
import {
  Controller,
  Post,
  Body,
  ConflictException,
  Get,
  Query,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { UsersService } from './users.service';
import * as bcrypt from 'bcrypt';
import { add } from 'node_modules/viem/_types/tempo/actions/validator';
import { JwtService } from '@nestjs/jwt';

import { UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt.guard';

@Controller('users')
export class UsersController {
  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
  ) {}

  @Post('register')
  async register(
    @Body() body: { email: string; password: string; address: string },
  ) {
    const existing = await this.usersService.findByEmail(body.email);
    if (existing) {
      throw new ConflictException('Email already in use');
    }

    const hashedPassword = await bcrypt.hash(body.password, 10);
    const user = await this.usersService.create(
      body.email,
      hashedPassword,
      body.address,
    );

    return {
      id: user._id,
      email: user.email,
    };
  }

  @UseGuards(JwtAuthGuard)
  @Get('getUserByEmail')
  async getByEmail(@Query('email') email: string) {
    const user = await this.usersService.findByEmail(email);
    if (!user) {
      throw new NotFoundException('User not found');
    }
    return {
      id: user._id,
      email: user.email,
    };
  }

  @UseGuards(JwtAuthGuard)
  @Get('getAll')
  async getAllUsers() {
    const users = await this.usersService.findAll();
    if (!users || users.length === 0) {
      throw new NotFoundException('No Users found');
    }
    return users.map((user) => ({
      id: user._id,
      email: user.email,
      address: user.address,
    }));
  }

  @Post('login')
  async login(@Body() body: { email: string; password: string }) {
    const user = await this.usersService.findByEmail(body.email);
    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const passwordMatch = await bcrypt.compare(body.password, user.password);
    if (!passwordMatch) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const token = this.jwtService.sign({
      sub: user._id,
      email: user.email,
    });

    return { access_token: token };
  }
}
