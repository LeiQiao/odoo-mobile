/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 */
'use strict';
import React, {
  AppRegistry,
  Component,
  StyleSheet,
  Text,
  TextInput,
  View,
  Modal,
  Navigator,
  TouchableOpacity
} from 'react-native';

import MainView from './js/MainView';
  
var NavigationBarRouteMapper = {
  LeftButton(route, navigator, index, navState) {
  },
  
  RightButton(route, navigator, index, navState) {
  },            
  Title(route, navigator, index, navState) {
  },
};

class OdooMobile extends Component {
  renderScene(route, navigator){
    return <MainView/>;
  }
  
  render() {
    return (
      <Navigator
        style={styles.container}
        navigationBar={
          <Navigator.NavigationBar
            routeMapper={NavigationBarRouteMapper}
            style={styles.navBar}
          />
        }
        initialRoute={{name:'首页', component:MainView, sceneConfig:Navigator.SceneConfigs.FloatFromRight}}
        renderScene={(route, navigator) => {
          return <route.component {...route.params} navigator={navigator} />
        }}
        configureScene={(route) => {
          if( route.sceneConfig == null )
          {
            route.sceneConfig = Navigator.SceneConfigs.FloatFromRight;
          }
          return route.sceneConfig;
        }}
      />);
    }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  navBar: {
    backgroundColor: 'white',
  },
  navBarText: {
    fontSize: 16,
    marginVertical: 10,
  },
  navBarTitleText: {
    color: '#000000',
    fontWeight: '500',
    marginVertical: 9,
  },
  navBarLeftButton: {
    paddingLeft: 10,
  },
  navBarRightButton: {
    paddingRight: 10,
  },
  navBarButtonText: {
    color: 'blue',
  },
});

AppRegistry.registerComponent('odooMobile', () => OdooMobile);
