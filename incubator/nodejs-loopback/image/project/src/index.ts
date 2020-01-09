// Copyright IBM Corp. 2019. All Rights Reserved.
// This file is licensed under the Apache-2.0 License.
// License text available at http://www.apache.org/licenses/LICENSE-2.0

import {ApplicationConfig, Constructor} from '@loopback/core';
import {Bootable} from '@loopback/boot';
import {RestApplication} from '@loopback/rest';
import {HealthComponent} from '@loopback/extension-health';
import {MetricsComponent} from '@loopback/extension-metrics';
import * as path from 'path';

// The user-app is mounted from the template
const userAppModule = '../user-app';
const userApp = require(userAppModule);

export type BootableRestApplication = RestApplication & Bootable;
export const DemoApplication: Constructor<BootableRestApplication> = userApp.DemoApplication;

export async function main(options: ApplicationConfig = {}) {
  // Set the current directory to the user-app module
  process.chdir(path.join(__dirname, userAppModule));
  const app = new DemoApplication(options);
  app.component(HealthComponent);
  app.component(MetricsComponent);
  await app.boot();
  await app.start();

  const url = app.restServer.url;
  console.log(`Server is running at ${url}`);
  console.log(`Try ${url}/ping`);

  return app;
}

if (require.main === module) {
  // Run the application
  const config = {
    rest: {
      port: +(process.env.PORT || 3000),
      host: process.env.HOST,
      openApiSpec: {
        // useful when used with OASGraph to locate your application
        setServersFromRequest: true,
      },
    },
  };
  main(config).catch(err => {
    console.error('Cannot start the application.', err);
    process.exit(1);
  });
}
