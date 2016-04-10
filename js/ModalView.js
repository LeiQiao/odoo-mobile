'use strict';
import React, {
  Modal,
  StyleSheet,
  View,
} from 'react-native';

class ModalView extends Modal {
  render() {
    var modalBackgroundStyle = {
      flex: 1,
      backgroundColor: 'white',
    };
    return (
      <View style={modalBackgroundStyle}>
        {super.render()}
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    // position: 'absolute',
    // top: 0,
    // bottom: 0,
    // left: 0,
    // right: 0,
    // backgroundColor: 'transparent',
      flex: 1,
    justifyContent: 'center',
    backgroundColor: '#FFFFFF',
  },
});