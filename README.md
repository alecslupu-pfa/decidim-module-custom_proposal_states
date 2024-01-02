# Module Decidim Custom Proposal States 

## Overview

The Custom Proposal States module is a plugin for Decidim, designed to enhance the flexibility and control over the proposal answering process. This module allows administrators and valuators to create, assign, and manage custom states for proposals, providing a more tailored approach to handle community proposals.

## Acknowledgments

The module has been financed by the city of Lyon as well as the Civic Engagement Commission of New York, and developed by Alex Lupu for Open Source Politics. 


## Installation

To add this module to your Decidim instance, follow these steps:

1. Add the module to your Gemfile:

   ```ruby
   gem 'decidim-custom_proposal_states'
   ```

2. Run the bundle command to install the gem:

   ```bash
   bundle install
   ```

3. Migrate your database to apply new changes:

   ```bash
   rails db:migrate
   ```

## Usage

- **Creating a New State:**
  - Click on the "States" button in the proposal list view in the back office.
  - Enter the name and token of the new state and save.
- **Assigning States to Proposals:**
  - Enable answers to proposals;
  - Select a proposal from the list and click on the answer button;
  - Choose the desired state.
- **Deleting States:**
  - Click on the "States" button in the proposal list view in the back office.
  - Choose the state to delete and confirm the action.

## Best Practices

- Define clear and meaningful state names and descriptions.
- Regularly review and update the custom states to ensure they remain relevant.
- Train your team on the significance and use of each state for consistency.

## Support

For support, you can post an issue on this repository. 

## Contributing

See [Decidim](https://github.com/decidim/decidim).

## License

This module is released under the [GNU Affero General Public License](https://www.gnu.org/licenses/agpl-3.0.en.html), which is the same license as Decidim itself.
