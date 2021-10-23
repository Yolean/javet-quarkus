package se.yolean.quarkustest.javet;

import javax.enterprise.context.ApplicationScoped;
import javax.enterprise.event.Observes;

import com.caoccao.javet.enums.JSRuntimeType;
import com.caoccao.javet.interop.loader.IJavetLibLoadingListener;
import com.caoccao.javet.interop.loader.JavetLibLoader;

import io.quarkus.logging.Log;
import io.quarkus.runtime.StartupEvent;

@ApplicationScoped
public class JavetLibLoadingListener implements IJavetLibLoadingListener {

  void onStart(@Observes StartupEvent ev) {
    Log.info("Customizing Javet lib loading");
    System.load("/usr/lib/x86_64-linux-gnu/libjavet-node-linux-x86_64.v.1.0.1.so");
    System.load("/usr/lib/x86_64-linux-gnu/libjavet-v8-linux-x86_64.v.1.0.1.so");
    JavetLibLoader.setLibLoadingListener(this);
  }

  @Override
  public boolean isLibInSystemPath(JSRuntimeType jsRuntimeType) {
    return true;
  }

}
