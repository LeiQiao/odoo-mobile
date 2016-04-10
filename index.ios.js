/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 */
'use strict';
import React, {
  AppRegistry,
  Component,
  StyleSheet,
  View,
} from 'react-native';

import MainView from './js/MainView';
import LoginView from './js/LoginView';
import SlideMenuView from './js/SlideMenuView';
import MenuListView from './js/MenuListView';
import WindowView from './js/WindowView';

class OdooMobile extends Component {
  render() {
    return (
      <View style={styles.container}>
      </View>
    );
  }
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FFFFFF',
  },
});

AppRegistry.registerComponent('odooMobile', () => OdooMobile);
