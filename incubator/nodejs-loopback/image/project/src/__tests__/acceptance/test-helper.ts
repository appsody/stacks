import {main, BootableRestApplication} from '../..';
import {
  createRestAppClient,
  givenHttpServerConfig,
  Client,
} from '@loopback/testlab';

export async function setupApplication(): Promise<AppWithClient> {
  const restConfig = givenHttpServerConfig({
    // Customize the server configuration here.
    // Empty values (undefined, '') will be ignored by the helper.
    //
    // host: process.env.HOST,
    // port: +process.env.PORT,
  });

  const app = await main({
    rest: restConfig,
  });

  const client = createRestAppClient(app);

  return {app, client};
}

export interface AppWithClient {
  app: BootableRestApplication;
  client: Client;
}
