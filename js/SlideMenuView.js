'use strict';
import React, {
  AppRegistry,
  Component,
  StyleSheet,
  ListView,
  Text,
  View,
  Image,
  TouchableHighlight,
  NativeModules,
} from 'react-native';


class SlideMenuView extends Component {
  constructor(props) {
    super(props);
    var ds = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});
    this.state = {
      CompanyLogoImage: '',
      UserImage: '',
      UserName: '',
      Menus: '',
      dataSource: ds,
    };
    
    NativeModules.Preferences.get('CompanyLogoImage', (v) => {
      this.setState({CompanyLogoImage : v});
    });
    
    NativeModules.Preferences.get('UserImage', (v) => {
      this.setState({UserImage : v});
    });
    
    NativeModules.Preferences.get('UserName', (v) => {
      this.setState({UserName : v});
    });
    
    NativeModules.Preferences.get('Menus', (v) => {
      this.setState({Menus : v});
      var rows = [];
      for( var i=0; i<v.length; i++ )
      {
        if( !v[i].parent_id )
        {
          rows.push(v[i]);
        }
      }
      this.setState({dataSource : ds.cloneWithRows(rows)});
    });
  }
  
  renderRow(rowData, sectionIndex, rowIndex) {
    return (
      <TouchableHighlight
        onPress={() => this.onMenu(rowData)}
        underlayColor='lightgray'>
        <View>
          <View style={styles.row}>
            <Text style={styles.rowText}>
              {rowData.name}
            </Text>
            <Image
              style={styles.rowAcc}
              source={require('image!jiantou')} />
          </View>
          <View style={styles.rowSeparator} />
        </View>
      </TouchableHighlight>
    );
  }
  
  render() {
    return (
      <View style={styles.container}>
        <TouchableHighlight
          onPress={this.onCompanySetting.bind(this)}
          underlayColor='rgba(0,0,0,0)'>
          <Image
            style={styles.companyLogoImage}
            source={{uri:'data:image/png;base64,'+this.state.CompanyLogoImage}} />
        </TouchableHighlight>
        <View style={styles.rowSeparator} />
        <ListView
          dataSource={this.state.dataSource}
          renderRow={this.renderRow.bind(this)} />
        <TouchableHighlight
          style={styles.settingButton}
          onPress={this.onPersonalSetting.bind(this)}
          underlayColor='rgba(0,0,0,0)'>
            <View style={styles.settingButtonView}>
            <Image
              style={styles.userImage}
              source={{uri:'data:image/png;base64,'+this.state.UserImage}} />
            <Text style={styles.settingText}>{this.state.UserName}</Text>
          </View>
        </TouchableHighlight>
      </View>
    );
  }
  
  onMenu(menuData) {
    NativeModules.Notification.postNotification('kWillLoadSubmenuNotification', menuData);
  }
  
  onCompanySetting() {
    NativeModules.Notification.postNotification('kShowCompanyInfoNotification', null);
  }
  
  onPersonalSetting() {
    NativeModules.Notification.postNotification('kShowPersonalInfoNotification', null);
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    paddingRight: 50,
  },
  companyLogoImage: {
    marginTop: 20,
    alignSelf: 'center',
    height: 100,
    width: 200,
    resizeMode: 'contain',
  },
  row: {
    flexDirection: 'row',
    height: 44,
  },
  rowText: {
    flex:1,
    fontSize: 16,
    marginLeft: 10,
    alignSelf: 'center',
  },
  rowAcc: {
    marginRight: 20,
    height:15,
    alignSelf: 'center',
  },
  rowSeparator: {
    height: 1,
    backgroundColor: '#CCCCCC',
  },
  settingButton: {
    marginLeft: 10,
    padding: 10,
    alignSelf: 'flex-start',
  },
  settingButtonView:{
    flexDirection: 'row',
  },
  userImage: {
    width:25,
    height: 25,
    marginRight: 10,
  },
  settingText: {
    flex:1,
    fontSize: 16,
    alignSelf: 'center',
  },
});

AppRegistry.registerComponent('SlideMenuView', () => SlideMenuView);

