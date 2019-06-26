# Stacks

This respository holds the default set of stacks avalible from the appsody cli. Stacks allow for rapid development whilst giving the stack developer the ability to control the overall applications that are created from it. 

Appsody provides pre-configured application stacks that enable rapid development of quality microservice-based applications. Stacks include a base container image and project templates which act as a starting point for your application development.

Appsody stacks include language runtimes, frameworks and any additonal libraries and tools that are required to simplify your local application development. Stacks are an easy way to manage consistency and adopt best practices across many applications.

To find out more about Appsody check out [appsody.dev](https://appsody.dev).

## Repository Structure
Stacks are catagorized as either stable, incubator or experimental depending on the content of the stack.

- `stable/:` Stable stacks meet a set of technical requirements which are yet to be defined.

- `incubator/:` The stacks in the incubator folder are actively being worked on to satisfy the stable critria.

- `experimental/:` Exprimental stacks are not being actively been worked on and may not fulfill the requirements of an Appsody stack. These can be used for trying out specific capabilites or proof of concept work.

**Stacks currently available:**
- [nodejs](incubator/nodejs/README.md) - Node.js Runtime
- [nodejs-express](incubator/nodejs-express/README.md) - Express web framework for Node.js
- [java-microprofile](incubator/java-microprofile/README.md) - Microprofile using Adopt OpenJDK and Maven
- [java-spring-boot2](incubator/java-spring-boot2/README.md) - Spring Boot using IBM Java SDK and Maven

Click here to find out more about [Appsody stacks](https://github.com/appsody/docs/blob/master/docs/stacks/stacks-overview.md).

## Creating a Stack
We are actively working to create new stacks so that more people can adopt Appsody. If you find that none of the existing stacks meet your needs please reach out to us on the [Appsody Slack](https://appsody-slack.eu-gb.mybluemix.net/) or create a new GitHub issue to track the discussion.

We always welcome any contributions. If you wanted to create your own stack for a framework or language that we do not currently support, please review the [contributing guidelines](../../CONTRIBUTING.md) and follow the steps outlined in [creating a stack](create-or-modify.md#creating-a-stack).

## Need help?
If you have a question that you can't find an answer to, we would also like to hear about that too. You can reach out to the community for assistance on [Slack](https://appsody-slack.eu-gb.mybluemix.net/).