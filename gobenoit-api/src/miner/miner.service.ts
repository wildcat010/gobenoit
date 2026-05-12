import {
  BadRequestException,
  Injectable,
  InternalServerErrorException,
} from '@nestjs/common';
import { BlockchainService } from '../blockchain/blockchain.service';
import { MINER_MANAGER_ABI } from 'src/blockchain/abis/minerManager.abi';
import { GBN_TOKEN_ABI } from 'src/blockchain/abis/GBNToken.abi';
import { privateKeyToAccount } from 'viem/accounts';
import { parseEther, formatUnits } from 'viem';

const MINER_MANAGER_ADDRESS = '0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9';
const GBN_TOKEN_ADDRESS = '0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512';

@Injectable()
export class MinerService {
  constructor(private readonly blockchainService: BlockchainService) {}

  async buyTokens(ethAmount: string, privateKey: `0x${string}`) {
    if (!ethAmount) {
      throw new Error('ethAmount is required');
    }

    const walletClient = this.blockchainService.getWalletClient(privateKey);
    const txHash = await walletClient.writeContract({
      address: MINER_MANAGER_ADDRESS,
      abi: MINER_MANAGER_ABI,
      functionName: 'buyTokens',
      value: parseEther(ethAmount),
    });

    const tokensPurchased = parseEther(ethAmount) * BigInt(1000);

    return {
      txHash,
      ethSpent: ethAmount + ' ETH',
      tokensPurchased: formatUnits(tokensPurchased, 18) + ' GBN',
    };
  }

  async getBalanceOf(address: `0x${string}`) {
    const balance = await this.blockchainService.client.readContract({
      address: GBN_TOKEN_ADDRESS,
      abi: GBN_TOKEN_ABI,
      functionName: 'balanceOf',
      args: [address],
    });

    return {
      address,
      balance: formatUnits(balance, 18) + ' GBN',
    };
  }

  async buyMiner(quantity: number, privateKey: `0x${string}`) {
    try {
      const walletClient = this.blockchainService.getWalletClient(privateKey);
      const totalCost = parseEther('100') * BigInt(quantity);

      // approve MinerManager to burn tokens
      await walletClient.writeContract({
        address: GBN_TOKEN_ADDRESS,
        abi: GBN_TOKEN_ABI,
        functionName: 'approve',
        args: [MINER_MANAGER_ADDRESS, totalCost],
      });

      // buy miners
      const txHash = await walletClient.writeContract({
        address: MINER_MANAGER_ADDRESS,
        abi: MINER_MANAGER_ABI,
        functionName: 'buyMiner',
        args: [BigInt(quantity)],
      });

      const receipt =
        await this.blockchainService.client.waitForTransactionReceipt({
          hash: txHash,
        });

      return {
        quantity,
        totalCost: formatUnits(totalCost, 18) + ' GBN',
        txHash,
        status: receipt.status,
      };
    } catch (error: any) {
      if (error.message.includes('EnforcedPause')) {
        throw new Error(
          'The contract is currently paused. Please try again later.',
        );
      }

      if (error.shortMessage?.includes('Insufficient GBN balance')) {
        throw new BadRequestException('Insufficient GBN balance');
      }
      throw new InternalServerErrorException('Blockchain transaction failed');
    }
  }

  async claim(privateKey: `0x${string}`) {
    const walletClient = this.blockchainService.getWalletClient(privateKey);
    const account = privateKeyToAccount(privateKey);

    const pending = (await this.blockchainService.client.readContract({
      address: MINER_MANAGER_ADDRESS,
      abi: MINER_MANAGER_ABI,
      functionName: 'pendingReward',
      args: [account.address],
    })) as bigint;

    const fee = pending / BigInt(2);

    const txHash = await walletClient.writeContract({
      address: MINER_MANAGER_ADDRESS,
      abi: MINER_MANAGER_ABI,
      functionName: 'claim',
    });

    const receipt =
      await this.blockchainService.client.waitForTransactionReceipt({
        hash: txHash,
      });

    return {
      txHash,
      status: receipt.status,
      reward: formatUnits(pending, 18) + ' GBN',
      feePaid: formatUnits(fee, 18) + ' GBN',
    };
  }

  async pendingReward(address: `0x${string}`) {
    const pending = (await this.blockchainService.client.readContract({
      address: MINER_MANAGER_ADDRESS,
      abi: MINER_MANAGER_ABI,
      functionName: 'pendingReward',
      args: [address],
    })) as bigint;

    return {
      address: address,
      pendingReward: formatUnits(pending, 18) + ' GBN',
    };
  }

  async pause(pause: boolean, privateKey: `0x${string}`) {
    const walletClient = this.blockchainService.getWalletClient(privateKey);
    const txHash = await walletClient.writeContract({
      address: MINER_MANAGER_ADDRESS,
      abi: MINER_MANAGER_ABI,
      functionName: pause ? 'pause' : 'unpause',
    });

    const receipt =
      await this.blockchainService.client.waitForTransactionReceipt({
        hash: txHash,
      });

    return {
      txHash,
      status: receipt.status,
      paused: pause,
    };
  }
}
