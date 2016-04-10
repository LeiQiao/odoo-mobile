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
  DeviceEventEmitter,
} from 'react-native';


class MenuListView extends Component {
  constructor(props) {
    super(props);
    
    var ds = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});
    this.state = {
      dataSource: ds,
    };
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
      <View style={styles.nav} />
        <ListView
          style={styles.listView}
          dataSource={this.state.dataSource}
          renderRow={this.renderRow.bind(this)} />
      </View>
    );
  }
  
  componentDidMount() {
　　DeviceEventEmitter.addListener('kDidLoadSubmenuNotification', (f) => this.onSubmenuDidLoad(f));
  }

  componentWillUnmount() {
　　DeviceEventEmitter.removeAllListeners('kDidLoadSubmenuNotification');
  }
  
  onSubmenuDidLoad(response) {
    if( !response.success ) return;
    if( response.responseObject.Menu.id != this.props.id ) return;
    
    var subMenus = response.responseObject.SubMenus;
    this.setState({dataSource : this.state.dataSource.cloneWithRows(subMenus)});
  }
  
  onMenu(menuData) {
    NativeModules.Notification.postNotification('kWillLoadSubmenuNotification', menuData);
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  nav: {
    height: 64,
  },
  listView: {
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
});

AppRegistry.registerComponent('MenuListView', () => MenuListView);

