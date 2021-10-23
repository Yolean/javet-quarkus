package se.yolean.quarkustest.javet;

import java.nio.file.Path;

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
    JavetLibLoader.setLibLoadingListener(this);
  }

  @Override
  public Path getLibPath(JSRuntimeType jsRuntimeType) {
      return Path.of("/");
  }

  @Override
  public boolean isDeploy(JSRuntimeType jsRuntimeType) {
      return false;
  }

}
